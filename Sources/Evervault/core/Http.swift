import Foundation

internal struct Http {
    let config: HttpConfig
    let teamId: String
    let appId: String
    let context: String


    private let keysLoader: HttpKeysLoader

    init(config: HttpConfig, teamId: String, appId: String, context: String) {
        self.config = config
        self.teamId = teamId
        self.appId = appId
        self.context = context
        self.keysLoader = HttpKeysLoader(url: URL(string: "\(config.keysUrl)/\(teamId)/apps/\(appId)?context=\(context)")!)
    }

    func loadKeys() async throws -> CageKey {
        try await keysLoader.loadKeys()
    }
}
