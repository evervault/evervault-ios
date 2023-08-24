import Foundation

/// The Evervault class provides encryption capabilities for iOS and macOS platforms through the Evervault iOS SDK.
///
/// To use the Evervault iOS SDK, you need to configure the SDK with your Team ID and App ID using the `configure` function. Once configured, you can use the `encrypt` function to securely encrypt sensitive data.
///
/// ## Example
/// ```swift
/// Evervault.shared.configure(teamId: "YOUR_TEAM_ID", appId: "YOUR_APP_ID")
/// let encryptedData = try await Evervault.shared.encrypt("Sensitive Data")
/// ```
///
/// The Evervault class also provides convenience initializers for configuring the Evervault iOS SDK with your Team ID and App ID.
///
/// - Note: The Evervault iOS SDK documentation may provide more detailed information and additional examples.
public class Evervault {

    /// The shared instance of the `Evervault` class.
    ///
    /// The `shared` property provides access to the singleton instance of the `Evervault` class, allowing you to configure and use the Evervault iOS SDK.
    ///
    /// ## Declaration
    /// ```swift
    /// public static let shared = Evervault()
    /// ```
    ///
    /// ## Example
    /// ```swift
    /// Evervault.shared.configure(teamId: "YOUR_TEAM_ID", appId: "YOUR_APP_ID")
    /// let encryptedData = try await Evervault.shared.encrypt("Sensitive Data")
    /// ```
    ///
    /// The `shared` property allows you to access the singleton instance of the `Evervault` class. You can use it to configure the Evervault iOS SDK with your Team ID and App ID, as well as to call other encryption functionalities like the `encrypt` method.
    ///
    /// It's recommended to configure the Evervault iOS SDK using the `shared` instance before using any other functionalities.
    ///
    /// - Note: The Evervault iOS SDK documentation may provide more detailed information and additional examples.
    public static let shared = Evervault()

    private var client: Client?

    /// Configures the Evervault iOS SDK with the specified Team ID and App ID.
    ///
    /// - Parameters:
    ///   - teamId: The Team ID provided by Evervault. This uniquely identifies your team.
    ///   - appId: The App ID provided by Evervault. This uniquely identifies your app.
    ///   - customConfig: An optional custom configuration for advanced settings. Default is `nil`.
    ///
    /// Only use this initializer if you need multiple instances of `Evervault` with different settings. Otherwise use `configure` on a `shared` instance.
    ///
    convenience public init(teamId: String, appId: String, customConfig: CustomConfig? = nil) {
        self.init()
        configure(teamId: teamId, appId: appId, customConfig: customConfig)
    }

    private init() {
    }

    /// Configures the Evervault iOS SDK with the specified Team ID, App ID, and an optional custom configuration.
    ///
    /// - Parameters:
    ///   - teamId: The Team ID provided by Evervault. This uniquely identifies your team.
    ///   - appId: The App ID provided by Evervault. This uniquely identifies your app.
    ///   - customConfig: An optional custom configuration for advanced settings. Default is `nil`.
    ///
    /// The `configure` function must be called before using any other functionalities of the Evervault iOS SDK. It establishes a connection between your app and the Evervault encryption service by providing the necessary identification information (Team ID and App ID).
    ///
    /// Additionally, you can provide a `CustomConfig` object to customize advanced settings for the Evervault iOS SDK.
    ///
    /// It's recommended to call the `configure` function early in your app's lifecycle, such as during app initialization or in the `application(_:didFinishLaunchingWithOptions:)` method.
    ///
    /// Once the Evervault iOS SDK is configured, you can use other encryption functionalities, such as the `encrypt` method, to securely encrypt sensitive data.
    ///
    /// ## Example
    /// ```swift
    /// Evervault.shared.configure(teamId: "YOUR_TEAM_ID", appId: "YOUR_APP_ID")
    /// ```
    ///
    /// Make sure to replace `"YOUR_TEAM_ID"` and `"YOUR_APP_ID"` with your actual Evervault Team ID and App ID.
    ///
    /// - Note: The Evervault iOS SDK documentation may provide more detailed information and additional examples.
    public func configure(teamId: String, appId: String, customConfig: CustomConfig? = nil) {
        let config = Config(
            teamId: teamId,
            appId: appId,
            configUrls: customConfig?.urls ?? ConfigUrls(),
            publicKey: customConfig?.publicKey
        )
        self.client = Client(
            config: config,
            http: config.http,
            evervaultFactory: CryptoEvervaultFactory(),
            debugMode: customConfig?.isDebugMode
        )
    }

    /// Encrypts the provided data using the Evervault encryption service.
    ///
    /// - Parameter data: The data to be encrypted. Supported data types include Boolean, Numerics, Strings, Arrays, Dictionaries, and Data.
    /// - Returns: The encrypted data. The return type is `Any`, and the caller is responsible for safely casting the result based on the original data type.
    /// - Throws: An error if the encryption process fails.
    ///
    /// ## Declaration
    /// ```swift
    /// public func encrypt(_ data: Any) async throws -> Any
    /// ```
    ///
    /// ## Example
    /// ```swift
    /// let encryptedData = try await Evervault.shared.encrypt("Sensitive Data")
    /// ```
    ///
    /// The `encrypt` function allows you to securely encrypt sensitive data using the Evervault encryption service. It supports a variety of data types, including Boolean, Numerics, Strings, Arrays, Dictionaries, and Data.
    ///
    /// The function returns the encrypted data as `Any`, and the caller is responsible for safely casting the result based on the original data type. For Boolean, Numerics, and Strings, the encrypted data is returned as a String. For Arrays and Dictionaries, the encrypted data maintains the same structure but is encrypted. For Data, the encrypted data is returned as encrypted Data.
    ///
    /// Note that the encryption process is performed asynchronously using the `async` and `await` keywords. It's recommended to call this function from within an `async` context or use `await` when calling it.
    ///
    /// - Note: The Evervault iOS SDK documentation may provide more detailed information and additional examples.
    public func encrypt(_ data: Any) async throws -> Any {
        guard let client = client else {
            throw EvervaultError.initializationError
        }
        return try await client.encrypt(data)
    }
    
    /// Decrypts the provided data using the Evervault encryption service
    ///
    /// - Parameter token: A short-lived client-side token generated through your backend application to decrypt data.
    /// - Parameter data: The data to be decrypted. Supported data types include Boolean, Numerics, Strings, Arrays, Dictionaries, and Data.
    /// - Returns: The decrypted data. The return type can b
    /// - Throws: An error if the decryption process fails.
    ///
    /// ## Declaration
    /// ```swift
    /// public func decrypt(token: String, data: Any) async throws -> T
    /// ```
    ///
    /// ## Example
    /// ```swift
    /// let decryptedData = try await Evervault.shared.decrypt("<token>", "<encryptedString>")
    /// ```
    ///
    /// The `decrypt` function allows you to decrypt data previously encrypted data using a short-lived client-side token provided by your backend application.
    /// Client-Side Tokens are time bound tokens that can be created using the Evervault's REST API or one of Evervault's backend SDKs.
    ///
    /// Note that the decryption process is performed asynchronously using the `async` and `await` keywords. It's recommended to call this function from within an `async` context or use `await` when calling it.
    ///
    /// - Note: The Evervault iOS SDK documentation may provide more detailed information and additional examples.
    public func decrypt<T>(token: String, data: Any) async throws -> T {
        guard let client = client else {
            throw EvervaultError.initializationError
        }
        return try await client.decrypt(token: token, data: data)
    }

}

private extension Config {
    var http: Http {
        return Http(
            config: httpConfig,
            teamId: teamId,
            appId: appId,
            context: "default"
        )
    }
}

private protocol EvervaultFactory {
    func createSharedSecretDeriver() -> SharedSecretDeriver
    func createDataCipherFactory() -> DataCipherFactory
}

private struct CryptoEvervaultFactory: EvervaultFactory {

    func createSharedSecretDeriver() -> SharedSecretDeriver {
        return CryptoSharedSecretDeriver()
    }

    func createDataCipherFactory() -> DataCipherFactory {
        return CryptoDataCipherFactory()
    }
}

fileprivate struct Client {

    private let config: Config
    private let http: Http
    private let debugMode: Bool?

    private let cryptoLoader: CryptoLoader

    init(config: Config, http: Http, evervaultFactory: EvervaultFactory, debugMode: Bool?) {
        self.config = config
        self.http = http
        self.debugMode = debugMode
        self.cryptoLoader = CryptoLoader(
            config: config,
            http: http,
            sharedSecretDeriver: evervaultFactory.createSharedSecretDeriver(),
            dataCipherFactory: evervaultFactory.createDataCipherFactory(),
            isInDebugMode: debugMode
        )
    }

    internal func encrypt(_ data: Any) async throws -> Any {
        let cipher = try await cryptoLoader.loadCipher()
        let handlers = DataHandlers(encryptionService: cipher)

        return try handlers.encrypt(data: data)
    }
        
    internal func decrypt<T>(token: String, data: Any) async throws -> T {
        let decrypted: (Any)?
        
        if let dataAsString = data as? String {
            let decryptedDict = try await http.decryptDictionary(token: token, data: ["data": dataAsString])
            decrypted = decryptedDict["data"]
        } else if let dataAsArray = data as? Array<String> {
            let decryptedDict = try await http.decryptDictionary(token: token, data: ["data": dataAsArray])
            decrypted = decryptedDict["data"]
        } else if let dataAsDict = data as? [String: Any] {
            decrypted = try await http.decryptDictionary(token: token, data: dataAsDict)
        } else {
            throw EvervaultError.unsupportedEncryptedTypeError
        }
        
        guard let castedDecrypted = decrypted as? T else {
            throw EvervaultError.invalidCast
        }
        
        return castedDecrypted
    }
}

/// A struct that represents custom configuration options for the Evervault iOS SDK.
///
/// The `CustomConfig` struct allows you to customize advanced settings for the Evervault iOS SDK. These settings include options like enabling debug mode, specifying custom URLs, or providing a public key for encryption.
///
/// It's important to note that the `CustomConfig` struct should not be used under normal circumstances, as the default configuration provided by the Evervault iOS SDK is typically sufficient for most use cases.
///
/// ## Example
/// ```swift
/// let customConfig = CustomConfig(isDebugMode: true, urls: ConfigUrls(keysUrl: "https://custom-keys-url.com"), publicKey: "CUSTOM_PUBLIC_KEY")
/// Evervault.shared.configure(teamId: "YOUR_TEAM_ID", appId: "YOUR_APP_ID", customConfig: customConfig)
/// ```
public struct CustomConfig {
    /// A boolean value indicating whether debug mode is enabled. Default is `nil`.
    public var isDebugMode: Bool?

    /// URLs for custom configuration options.
    public var urls: ConfigUrls?

    /// A public key to be used for encryption.
    public var publicKey: String?
}
