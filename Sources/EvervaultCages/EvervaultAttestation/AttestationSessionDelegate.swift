import Foundation

import AttestationBindings
import EvervaultCore


enum AttestationError: Error {
    case failedAttestation
}

public class TrustedAttestationSessionDelegate: NSObject, URLSessionDelegate {

    private let attestationData: [AttestationDataWithApp]

    public init(cageAttestationData: [AttestationDataWithApp]) {
        self.attestationData = cageAttestationData
    }

    public init(enclaveAttestationData: [EnclaveAttestationData]) {
        self.attestationData = enclaveAttestationData.map { enclaveAttestationData in
            return AttestationDataWithApp(
                cageName: enclaveAttestationData.enclaveName,
                appUuid: enclaveAttestationData.appUuid,
                provider: enclaveAttestationData.provider
            )
        }
    }

    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = (SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate])?.first else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let identifier = parseIdentifierFromHost(challenge.protectionSpace.host)
        
        AttestationDocumentCache.shared.getCachedAttestationDoc(identifier: identifier) { attestationDocB64 in
            guard let attestationDocB64 = attestationDocB64 else {
                print("Evervault: Failed to retrieve cached attestation document for \(identifier). Cancelling request.")
                challenge.sender?.cancel(challenge)
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            let remoteCertificateData = SecCertificateCopyData(certificate) as Data
            let certData = remoteCertificateData
            
            
            func attestConnectionRecursive(pcrsArray: inout [AttestationBindings.PCRs], pcrs: [PCRs], index: Int = 0) -> Bool {
                guard pcrs.count > index else {
                    let result = pcrsArray.withUnsafeBufferPointer { bufferPointer -> Bool in
                        guard let baseAddress = bufferPointer.baseAddress else { return false }
                        var certDataCopy = certData
                        return certDataCopy.withUnsafeMutableBytes { pointer -> Bool in
                            if let rawPointer = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                                
                                guard let attestationDocData = Data(base64Encoded: attestationDocB64) else {
                                    return false
                                }
                                
                                return attestationDocData.withUnsafeBytes { attestationDocBytesPointer -> Bool in
                                    let attestationDocRawPointer = attestationDocBytesPointer.baseAddress!.assumingMemoryBound(to: UInt8.self)
                                    let resultFromAttest = attest_cage(rawPointer, certData.count, baseAddress, pcrs.count, attestationDocRawPointer, attestationDocData.count)
                                    return resultFromAttest
                                }
                                
                            }
                            return false
                        }
                    }
                    return result
                }
                
                let pcrsAtIndex = pcrs[index]
                let pcr0CStr = pcrsAtIndex.pcr0.utf8CString
                let pcr1CStr = pcrsAtIndex.pcr1.utf8CString
                let pcr2CStr = pcrsAtIndex.pcr2.utf8CString
                let pcr8CStr = pcrsAtIndex.pcr8.utf8CString
                
                return pcr0CStr.withUnsafeBufferPointer { pcr0Bytes in
                    pcr1CStr.withUnsafeBufferPointer { pcr1Bytes in
                        pcr2CStr.withUnsafeBufferPointer { pcr2Bytes in
                            pcr8CStr.withUnsafeBufferPointer { pcr8Bytes in
                                pcrsArray.append(AttestationBindings.PCRs(
                                    pcr_0: pcr0Bytes.baseAddress!,
                                    pcr_1: pcr1Bytes.baseAddress!,
                                    pcr_2: pcr2Bytes.baseAddress!,
                                    pcr_8: pcr8Bytes.baseAddress!
                                ))
                                
                                let attestResult = attestConnectionRecursive(pcrsArray: &pcrsArray, pcrs: pcrs, index: index + 1)
                                return attestResult
                            }
                        }
                    }
                }
            }
            
            guard let attestationData = self.attestationData.first(where: { $0.identifier == identifier }) else {
                print("Evervault: No matching PCRs specified for \(identifier). Not attesting connection.")
                completionHandler(.performDefaultHandling, nil)
                return
            }
            
            PcrManager.shared.fetchPcrs(identifier: identifier, provider: attestationData.provider, completion: { pcrs, error in
                guard let fetchedPcrs = pcrs, error == nil else {
                    print("Evervault: Error fetching PCRs or no PCRs found for \(identifier). Cancelling request.")
                    challenge.sender?.cancel(challenge)
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                
                var pcrsArray = [AttestationBindings.PCRs]()
                let result = attestConnectionRecursive(pcrsArray: &pcrsArray, pcrs: fetchedPcrs)
                                
                guard result else {
                    print("Evervault: Attestation failed for \(identifier). Cancelling authentication challenge.")
                    challenge.sender?.cancel(challenge)
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                
                completionHandler(.performDefaultHandling, nil)
                  
            })
        }
    }
}


private func parseIdentifierFromHost(_ hostname: String) -> String {
    let hostnameTokens = hostname.split(separator: ".")
    // Check if nonce prefix is present
    if hostnameTokens.count > 1 && hostnameTokens[1] == "attest" {
        return "\(hostnameTokens[2]).\(hostnameTokens[3])"
    } else {
        return "\(hostnameTokens[0]).\(hostnameTokens[1])"
    }
}
