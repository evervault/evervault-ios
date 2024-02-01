import Foundation

import EvervaultCore
import AttestationBindings

extension Evervault {
    
    @available(*, deprecated, message: "Use enclaveAttestationSession from EvervaultEnclaves package instead. This method will be removed in future versions.")
    public static func cageSession(cageAttestationData: AttestationData...) -> URLSession {
        return URLSession(configuration: .default, delegate: AttestationSessionDelegate(cageAttestationData: cageAttestationData), delegateQueue: nil)
    }
    
    @available(*, deprecated, message: "Use enclaveAttestationSession from EvervaultEnclaves package instead. This method will be removed in future versions.")
    public static func cageAttestationSession(cageAttestationData: AttestationDataWithApp...) -> URLSession {
        return URLSession(configuration: .default, delegate: TrustedAttestationSessionDelegate(cageAttestationData: cageAttestationData), delegateQueue: nil)
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
            let pcr0CStr = pcrsAtIndex.pcr0?.withCString { $0 } ?? nil
            let pcr1CStr = pcrsAtIndex.pcr1?.withCString { $0 } ?? nil
            let pcr2CStr = pcrsAtIndex.pcr2?.withCString { $0 } ?? nil
            let pcr8CStr = pcrsAtIndex.pcr8?.withCString { $0 } ?? nil

            let pcrStruct = AttestationBindings.PCRs(
                pcr_0: pcr0CStr,
                pcr_1: pcr1CStr,
                pcr_2: pcr2CStr,
                pcr_8: pcr8CStr
            )

            pcrsArray.append(pcrStruct)

            return attestConnectionRecursive(pcrsArray: &pcrsArray, pcrs: pcrs, index: index + 1)
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

private func parseCageNameFromHost(_ hostname: String) -> String {
    let hostnameTokens = hostname.split(separator: ".")
    // Check if nonce prefix is present
    if hostnameTokens.count > 1 && hostnameTokens[1] == "attest" {
        return String(hostnameTokens[2])
    } else {
        return String(hostnameTokens[0])
    }
}
