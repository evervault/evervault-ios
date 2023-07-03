import Foundation

import AttestationBindings
import EvervaultCore

extension Evervault {
    public static func cageSession(cageAttestationData: AttestationData...) -> URLSession {
        return URLSession(configuration: .default, delegate: AttestationSessionDelegate(cageAttestationData: cageAttestationData), delegateQueue: nil)
    }
}

public struct AttestationData {
    let cageName: String
    let pcrs: [PCRs]

    public init(cageName: String, pcrs: PCRs...) {
        self.cageName = cageName
        self.pcrs = pcrs
    }
}

public struct PCRs {
    let pcr0: String
    let pcr1: String
    let pcr2: String
    let pcr8: String

    public init(pcr0: String, pcr1: String, pcr2: String, pcr8: String) {
        self.pcr0 = pcr0
        self.pcr1 = pcr1
        self.pcr2 = pcr2
        self.pcr8 = pcr8
    }
}

class AttestationSessionDelegate: NSObject, URLSessionDelegate {

    let cageAttestationData: [AttestationData]

    init(cageAttestationData: [AttestationData]) {
        self.cageAttestationData = cageAttestationData
    }


    func urlSession(_ session: URLSession,
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


private func parseCageNameFromHost(_ hostname: String) -> String {
    let hostnameTokens = hostname.split(separator: ".")
    // Check if nonce prefix is present
    if hostnameTokens.count > 1 && hostnameTokens[1] == "attest" {
        return String(hostnameTokens[2])
    } else {
        return String(hostnameTokens[0])
    }
}
