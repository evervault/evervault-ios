import Foundation

public struct PCRs: Decodable {
    public let pcr0: String?
    public let pcr1: String?
    public let pcr2: String?
    public let pcr8: String?

    public init(pcr0: String? = nil, pcr1: String? = nil, pcr2: String? = nil, pcr8: String? = nil) {
        self.pcr0 = pcr0
        self.pcr1 = pcr1
        self.pcr2 = pcr2
        self.pcr8 = pcr8
    }
}

public struct AttestationDataWithApp {
    public let name: String
    public let appUuid: String
    public let provider: (@escaping ([PCRs]?, Error?) -> Void) -> Void

    public init(name: String, appUuid: String, pcrs: PCRs...) {
        self.name = name
        self.appUuid = appUuid
        self.provider = { completion in
            completion(pcrs, nil)
        }
    }
    
    public init(name: String, appUuid: String, provider: @escaping (@escaping ([PCRs]?, Error?) -> Void) -> Void) {
        self.name = name
        self.appUuid = appUuid
        self.provider = provider
    }
    
    public var identifier: String {
        return "\(name).\(appUuid)"
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
        return AttestationDataWithApp(name: enclaveName, appUuid: appUuid, provider: provider)
    }
}
