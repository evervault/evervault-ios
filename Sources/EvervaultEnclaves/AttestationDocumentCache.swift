import Foundation

public class AttestationDocumentCache {
    
    public static let shared = AttestationDocumentCache()
    private let helper = AttestationDocumentHttpHelper.shared
    private let backgroundQueue = DispatchQueue(label: "com.evervault.attestationDocQueue")
    
    private init() {
        print("Evervault: Started polling for attestation docs every \(refreshInterval) seconds")
        scheduleCacheUpdate()
    }
    
    private var attestationDocMap: [String: String?] = [:]
    
    private let refreshInterval: TimeInterval = {
        if let intervalString = ProcessInfo.processInfo.environment["EV_ATTESTATION_DOC_POLLING_INTERVAL"],
           let interval = TimeInterval(intervalString) {
            return interval
        } else {
            // Five minutes = 300
            return 300
        }
    }()
    
    //Pull in all new ADs and then schedule it after refreshInterval
    private func updateCache() {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            self.updateCacheWithAllAttestationDocs()
            self.scheduleCacheUpdate()
        }
    }
    
    private func scheduleCacheUpdate() {
        backgroundQueue.asyncAfter(deadline: .now() + refreshInterval) { [weak self] in
            self?.updateCache()
        }
    }
    
    private func updateCacheWithAllAttestationDocs() {
        for identifier in self.attestationDocMap.keys {
            updateCacheWithSpecificAttestationDoc(identifier: identifier)
        }
    }
    
    private func updateCacheWithSpecificAttestationDoc(identifier: String) {
        self.helper.fetchAttestationDoc(host: "enclave", identifier: identifier) { result in
            switch result {
            case .success(let attestationDoc):
                print("Evervault: Received Attestation Document for ", identifier)
                self.attestationDocMap[identifier] = attestationDoc
                
            case .failure(let enclaveError):
                print("Evervault: Error fetching attestation document for \(identifier). Error: \(enclaveError.localizedDescription)")
            }
        }
    }
    
    public func fetchAttestationDocumentAsync(identifier: String) async -> String? {
        await withCheckedContinuation { continuation in
            getCachedAttestationDoc(identifier: identifier) { attestationDoc in
                continuation.resume(returning: attestationDoc)
            }
        }
    }
    
    func getCachedAttestationDoc(identifier: String, completion: @escaping (String?) -> Void) {
        // If the identifier is already in the map return AD.
        if let cachedAttestationDoc = attestationDocMap[identifier] {
            completion(cachedAttestationDoc)
            return
        }
        
        self.helper.fetchAttestationDoc(host: "enclave", identifier: identifier) { result in
            switch result {
            case .success(let attestationDoc):
                print("Evervault: Fetched Attestation Document for \(identifier)")
                self.attestationDocMap[identifier] = attestationDoc
                completion(attestationDoc)
                
            case .failure(let enclaveError):
                print("Evervault: Error fetching attestation document for \(identifier). Error: \(enclaveError.localizedDescription)")
                completion(nil)
            }
        }
    }

}
