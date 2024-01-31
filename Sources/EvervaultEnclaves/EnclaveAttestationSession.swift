//
//  File.swift
//  
//
//  Created by Donal Tuohy on 02/01/2024.
//

import Foundation

import EvervaultCages
import EvervaultCore


extension Evervault {
    public static func enclaveAttestationSession(enclaveAttestationData: EnclaveAttestationData...) async -> URLSession {
        
        // prefetch the attestation documents load into cache
        await initialiseAttestationDocumentCache(enclaveAttestationData: enclaveAttestationData)

        // After prefetching is complete, configure and return the URLSession
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
