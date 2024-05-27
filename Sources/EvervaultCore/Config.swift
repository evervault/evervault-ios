import Foundation

private let KEYS_URL = "https://keys.evervault.com"
private let API_URL = "https://api.evervault.com"

private let DEBUG_KEY = CageKey(
    ecdhP256Key: "Al1/Mo85D7t/XvC3I+YYpJvP+OsSyxIbSrhtDhg1SClQ",
    ecdhP256KeyUncompressed: "BF1/Mo85D7t/XvC3I+YYpJvP+OsSyxIbSrhtDhg1SClQ2xdoyGpXYrplO/f8AZ+7cGkUnMF3tzSfLC5Io8BuNyw=",
    isDebugMode: true
)

private let MAX_FILE_SIZE_IN_MB = 25

internal struct Config {
    var teamId: String
    var appId: String
    var encryption: EncryptionConfig
    var httpConfig: HttpConfig
    var debugKey: CageKey = DEBUG_KEY

    init(teamId: String, appId: String, configUrls: ConfigUrls, publicKey: String?) {
        self.teamId = teamId
        self.appId = appId
        self.encryption = EncryptionConfig(publicKey: publicKey)
        self.httpConfig = HttpConfig(keysUrl: configUrls.keysUrl, apiUrl: configUrls.apiUrl)
    }

}

/// A struct that represents custom URLs for the Evervault iOS SDK configuration.
///
/// The `ConfigUrls` struct allows you to specify custom URLs for specific configuration options in the Evervault iOS SDK.
public struct ConfigUrls {
    /// The URL for the custom keys endpoint. Default is the Evervault keys URL.
    public var keysUrl: String = KEYS_URL
    public var apiUrl: String = API_URL
}

internal struct EncryptionConfig {
    var publicKey: String?

    let cipherAlgorithm: String = "aes-256-gcm"
    let keyLength: Int = 32 // bytes
    let ivLength: Int = 12 // bytes
    let authTagLength: Int = 128 // bits
    let publicHash: String = "sha256"
    let evVersion: String = "TEST" // (Tk9D) NIST-P256 KDF
    let maxFileSizeInMB: Int = MAX_FILE_SIZE_IN_MB
    let maxFileSizeInBytes: Int = MAX_FILE_SIZE_IN_MB * 1024 * 1024

    struct Header {
        let iss: String
        let version: Int
    }
}

internal struct HttpConfig {
    var keysUrl: String
    var apiUrl: String
}
