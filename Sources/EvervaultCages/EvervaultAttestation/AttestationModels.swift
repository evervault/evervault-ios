import Foundation

//Note: Move all of these into EvervaultAttestation on next major bump.
public struct PCRs: Decodable {
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
    public let provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void

    public init(cageName: String, appUuid: String, pcrs: PCRs...) {
        self.cageName = cageName
        self.appUuid = appUuid
        self.provider = { completion in
            completion(pcrs, nil)
        }
    }
    
    public init(cageName: String, appUuid: String, provider: @escaping (@escaping ([PCRs]?, Error?) -> Void) -> Void) {
        self.cageName = cageName
        self.appUuid = appUuid
        self.provider = provider
    }
    
    public var identifier: String {
        return "\(cageName).\(appUuid)"
    }
}

public struct EnclaveAttestationData {
    public let enclaveName: String
    public let appUuid: String
    public let provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void

    public init(enclaveName: String, appUuid: String, pcrs: PCRs...) {
        self.enclaveName = enclaveName
        self.appUuid = appUuid
        self.provider = { completion in
            completion(pcrs, nil)
        }
    }
    
    public init(enclaveName: String, appUuid: String, provider: @escaping (@escaping ([PCRs]?, Error?) -> Void) -> Void) {
        self.enclaveName = enclaveName
        self.appUuid = appUuid
        self.provider = provider
    }
    
    public var identifier: String {
        return "\(enclaveName).\(appUuid)"
    }

    public func toAttestationDataWithApp() -> AttestationDataWithApp {
        return AttestationDataWithApp(cageName: enclaveName, appUuid: appUuid, provider: provider)
    }
}
