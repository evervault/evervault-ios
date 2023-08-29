import Foundation

internal struct Http {
    let config: HttpConfig
    let teamId: String
    let appId: String
    let context: String


    private let keysLoader: HttpKeysLoader
    private let decrypter: HttpDecrypter

    init(config: HttpConfig, teamId: String, appId: String, context: String) {
        self.config = config
        self.teamId = teamId
        self.appId = appId
        self.context = context
        self.keysLoader = HttpKeysLoader(url: URL(string: "\(config.keysUrl)/\(teamId)/apps/\(appId)?context=\(context)")!)
        self.decrypter = HttpDecrypter(url: URL(string: "\(config.apiUrl)/decrypt")!)
    }

    func loadKeys() async throws -> CageKey {
        try await keysLoader.loadKeys()
    }
    
    func decrypt(token: String, data: Any) async throws -> Any {
        try await decrypter.decrypt(token: token, data: data)
    }
}
