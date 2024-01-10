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
    public static func enclaveAttestationSession(enclaveAttestationData: EnclaveAttestationData...) -> URLSession {
        return URLSession(configuration: .default, delegate: TrustedAttestationSessionDelegate(enclaveAttestationData: enclaveAttestationData), delegateQueue: nil)
    }
}
