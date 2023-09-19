//
//  File.swift
//  
//
//  Created by Donal Tuohy on 18/09/2023.
//

import Foundation

class AttestationDocumentCache {
    
    static let shared = AttestationDocumentCache()
    
    private init() {
        print("Started polling for attestation doc... every \(refreshInterval) seconds")
        scheduleCacheUpdate()
    }
    
    private var attestationDoc: String?
    
    // DispatchQueue for background operations
    private let backgroundQueue = DispatchQueue(label: "com.example.attestationDocQueue")
    
    // Two hours
    private let refreshInterval: TimeInterval = 7200
    
    private func fetchAttestationDoc() -> String? {
        // TODO: Replace this with request to cage for attestation doc.
        return "Newly Fetched Attestation Doc at \(Date())"
    }
    
    private func updateCache() {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let newAttestationDoc = self.fetchAttestationDoc() {
                self.attestationDoc = newAttestationDoc
                print("Cache updated:", newAttestationDoc) // <- Corrected here
                
                self.scheduleCacheUpdate()
            }
        }
    }
    
    private func scheduleCacheUpdate() {
        backgroundQueue.asyncAfter(deadline: .now() + refreshInterval) { [weak self] in
            self?.updateCache()
        }
    }
    
    func getCachedAttestationDoc() -> String? {
        return attestationDoc
    }
}
