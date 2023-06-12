import Foundation

public class Evervault {

    public static let shared = Evervault()

    private var client: Client?

    convenience public init(teamId: String, appId: String, customConfig: CustomConfig? = nil) {
        self.init()
        configure(teamId: teamId, appId: appId, customConfig: customConfig)
    }

    private init() {
    }

    public func configure(teamId: String, appId: String, customConfig: CustomConfig? = nil) {
        let config = Config(
            teamId: teamId,
            appId: appId,
            configUrls: customConfig?.urls ?? ConfigUrls(),
            publicKey: customConfig?.publicKey
        )
        self.client = Client(config: config, http: config.http, debugMode: customConfig?.isDebugMode)
    }

    public func encrypt(_ data: Any) async throws -> Any {
        guard let client = client else {
            throw EvervaultError.initializationError
        }
        return try await client.encrypt(data)
    }

}

private extension Config {
    var http: Http {
        return Http(
            config: httpConfig,
            teamId: teamId,
            appId: appId,
            context: "default" // "inputs"
        )
    }
}

fileprivate struct Client {

    private let config: Config
    private let http: Http
    private let debugMode: Bool?

    private let cryptoLoader: CryptoLoader

    init(config: Config, http: Http, debugMode: Bool?) {
        self.config = config
        self.http = http
        self.debugMode = debugMode
        self.cryptoLoader = CryptoLoader(config: config, http: http, isInDebugMode: debugMode)
    }

    public func encrypt(_ data: Any) async throws -> Any {
        let cipher = try await cryptoLoader.loadCipher()
        let handlers = DataHandlers(cipher: cipher)

        return try handlers.encrypt(data: data)
    }
}

public struct CustomConfig {
  var isDebugMode: Bool?
  var urls: ConfigUrls?
  var publicKey: String?
}
