import Foundation

import EvervaultCore

extension Evervault {
    public static func enclaveAttestationSession(enclaveAttestationData: EnclaveAttestationData...) async -> URLSession {
        
        // prefetch the attestation documents load into cache
        await initialiseAttestationDocumentCache(enclaveAttestationData: enclaveAttestationData)

        return URLSession(configuration: .default, delegate: TrustedAttestationSessionDelegate(enclaveAttestationData: enclaveAttestationData), delegateQueue: nil)
    }
    static func initialiseAttestationDocumentCache(enclaveAttestationData: [EnclaveAttestationData]) async {
        for data in enclaveAttestationData {
            let identifier = data.identifier
            let document = await AttestationDocumentCache.shared.fetchAttestationDocumentAsync(identifier: identifier)
        
            if document == nil {
                print("Failed to fetch attestation document for identifier: \(identifier)")
            }
        }
    }
}
