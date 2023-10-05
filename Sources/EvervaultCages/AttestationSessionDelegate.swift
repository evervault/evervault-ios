import Foundation

import AttestationBindings
import EvervaultCore

enum AttestationError: Error {
    case failedAttestation
}

extension Evervault {
    
    @available(*, deprecated, message: "Use cageAttestationSession instead. Cages now have trusted certs on a different domain. See: https://docs.evervault.com/products/cages#tls-termination")
    public static func cageSession(cageAttestationData: AttestationData...) -> URLSession {
        return URLSession(configuration: .default, delegate: AttestationSessionDelegate(cageAttestationData: cageAttestationData), delegateQueue: nil)
    }
    
    public static func cageAttestationSession(cageAttestationData: AttestationDataWithApp...) -> URLSession {
        return URLSession(configuration: .default, delegate: TrustedAttestationSessionDelegate(cageAttestationData: cageAttestationData), delegateQueue: nil)
    }
}

public struct AttestationData {
    public let cageName: String
    public let pcrs: [PCRs]

    public init(cageName: String, pcrs: PCRs...) {
        self.cageName = cageName
        self.pcrs = pcrs
    }
}


public struct AttestationDataWithApp {
    public let cageName: String
    public let appUuid: String
    public let pcrs: [PCRs]

    public init(cageName: String, appUuid: String, pcrs: PCRs...) {
        self.cageName = cageName
        self.appUuid = appUuid
        self.pcrs = pcrs
    }
    
    public var identifier: String {
        return "\(cageName).\(appUuid)"
    }
}


public struct PCRs {
    public let pcr0: String
    public let pcr1: String
    public let pcr2: String
    public let pcr8: String

    public init(pcr0: String, pcr1: String, pcr2: String, pcr8: String) {
        self.pcr0 = pcr0
        self.pcr1 = pcr1
        self.pcr2 = pcr2
        self.pcr8 = pcr8
    }
}

public class AttestationSessionDelegate: NSObject, URLSessionDelegate {

    private let cageAttestationData: [AttestationData]

    public init(cageAttestationData: [AttestationData]) {
        self.cageAttestationData = cageAttestationData
    }

    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
            let certificate = (SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate])?.first else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let remoteCertificateData = SecCertificateCopyData(certificate) as Data
        let cageName = parseCageNameFromHost(challenge.protectionSpace.host)

        let certData = remoteCertificateData

        func attestConnectionRecursive(pcrsArray: inout [AttestationBindings.PCRs], pcrs: [PCRs], index: Int = 0) -> Bool {
            guard pcrs.count > index else {
                let result = pcrsArray.withUnsafeBufferPointer { bufferPointer in
                    guard let baseAddress = bufferPointer.baseAddress else { return false }
                    var certDataCopy = certData
                    return certDataCopy.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
                        if let rawPointer = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                            return attest_connection(rawPointer, certData.count, baseAddress, pcrs.count)
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

                            return attestConnectionRecursive(pcrsArray: &pcrsArray, pcrs: pcrs, index: index + 1)
                        }
                    }
                }
            }
        }

        guard let pcrs = cageAttestationData.first(where: { $0.cageName == cageName }) else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        var pcrsArray = [AttestationBindings.PCRs]()
        let result = attestConnectionRecursive(pcrsArray: &pcrsArray, pcrs: pcrs.pcrs)

        guard result else {
            completionHandler(.rejectProtectionSpace, URLCredential(trust: challenge.protectionSpace.serverTrust!))
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}



public class TrustedAttestationSessionDelegate: NSObject, URLSessionDelegate {

    private let cageAttestationData: [AttestationDataWithApp]

    public init(cageAttestationData: [AttestationDataWithApp]) {
        self.cageAttestationData = cageAttestationData
    }

    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = (SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate])?.first else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let cageIdentifier = parseCageIdentifierFromHost(challenge.protectionSpace.host)
        
        AttestationDocumentCache.shared.getCachedAttestationDoc(cageIdentifier: cageIdentifier) { attestationDocB64 in
            guard let attestationDocB64 = attestationDocB64 else {
                print("Failed to get cached attestation doc for \(cageIdentifier)")
                completionHandler(.performDefaultHandling, nil)
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
            
            guard let pcrs = self.cageAttestationData.first(where: { $0.identifier == cageIdentifier }) else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            
            var pcrsArray = [AttestationBindings.PCRs]()
            let result = attestConnectionRecursive(pcrsArray: &pcrsArray, pcrs: pcrs.pcrs)
            
            
            guard result else {
                // Cancel the challenge
                challenge.sender?.cancel(challenge)
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
}

private func parseCageNameFromHost(_ hostname: String) -> String {
    let hostnameTokens = hostname.split(separator: ".")
    // Check if nonce prefix is present
    if hostnameTokens.count > 1 && hostnameTokens[1] == "attest" {
        return String(hostnameTokens[2])
    } else {
        return String(hostnameTokens[0])
    }
}

private func parseCageIdentifierFromHost(_ hostname: String) -> String {
    let hostnameTokens = hostname.split(separator: ".")
    // Check if nonce prefix is present
    if hostnameTokens.count > 1 && hostnameTokens[1] == "attest" {
        return "\(hostnameTokens[2]).\(hostnameTokens[3])"
    } else {
        return "\(hostnameTokens[0]).\(hostnameTokens[1])"
    }
}
