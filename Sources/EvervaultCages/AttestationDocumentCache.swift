//
//  File.swift
//  
//
//  Created by Donal Tuohy on 18/09/2023.
//

import Foundation

class AttestationDocumentCache {
    
    static let shared = AttestationDocumentCache()
    private let helper = AttestationDocumentHttpHelper.shared
    private let backgroundQueue = DispatchQueue(label: "com.evervault.attestationDocQueue")
    
    private init() {
        print("Started polling for attestation docs... every \(refreshInterval) seconds")
        scheduleCacheUpdate()
    }
    
    private var attestationDocMap: [String: String?] = [:]
    
    // Two hours = 72000
    private let refreshInterval: TimeInterval = 30
    
    //Pull in all new ADs and then scedule it after refreshInterval
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
        for cageIdentifier in self.attestationDocMap.keys {
            updateCacheWithSpecificAttestationDoc(cageIdentifier: cageIdentifier)
        }
    }
    
    private func updateCacheWithSpecificAttestationDoc(cageIdentifier: String) {
        helper.fetchCageAttestationDoc(cageIdentifier: cageIdentifier) { result in
            switch result {
            case .success(let attestationDoc):
                print("Received Attestation Document for ", cageIdentifier)
                self.attestationDocMap[cageIdentifier] = attestationDoc
                
            case .failure(let error):
                print("Error fetching attestation document for \(cageIdentifier). Error: \(error.localizedDescription)")
                // Handle the error accordingly here
            }
        }
    }
    
    func getCachedAttestationDoc(cageIdentifier: String, completion: @escaping (String?) -> Void) {
        // If the cageName is already in the map return AD.
        if let cachedAttestationDoc = attestationDocMap[cageIdentifier] {
            completion(cachedAttestationDoc)
            return
        }
        
        // If not there - fetch AD, add to cache and then return it
        helper.fetchCageAttestationDoc(cageIdentifier: cageIdentifier) { result in
            switch result {
            case .success(let attestationDoc):
                print("Received Attestation Document for \(cageIdentifier)")
                self.attestationDocMap[cageIdentifier] = attestationDoc
                completion(attestationDoc)
                
            case .failure(let error):
                print("Error fetching attestation document for \(cageIdentifier). Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
