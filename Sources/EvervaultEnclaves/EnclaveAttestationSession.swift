import Foundation

import EvervaultAttestation
import EvervaultCages
import EvervaultCore

extension Evervault {
    public static func enclaveAttestationSession(enclaveAttestationData: EnclaveAttestationData...) -> URLSession {
        return URLSession(configuration: .default, delegate: TrustedAttestationSessionDelegate(enclaveAttestationData: enclaveAttestationData), delegateQueue: nil)
    }
}