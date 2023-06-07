import CryptoKit
import Foundation

actor KeysLoader {

    private var activeTask: Task<Crypto, Error>?
    private var cachedKey: Crypto?

    private let config: Config
    private let http: Http
    private let isInDebugMode: Bool?

    init(config: Config, http: Http, isInDebugMode: Bool?) {
        self.config = config
        self.http = http
        self.isInDebugMode = isInDebugMode
    }

    func loadKeys() async throws -> Crypto {
        if let activeTask {
            return try await activeTask.value
        }

        let task = Task<Crypto, Error> {
            if let cachedKey {
                activeTask = nil
                return cachedKey
            }

            do {
                let result = try await fetchKeys()
                activeTask = nil
                return result
            } catch {
                activeTask = nil
                throw error
            }
        }

        activeTask = task

        return try await task.value
    }

    private func fetchKeys() async throws -> Crypto {
        let cageKey: CageKey
        if let publicKey = config.encryption.publicKey {
            cageKey = CageKey(publicKey: publicKey)
        } else if isInDebugMode == true {
            cageKey = config.debugKey
        } else {
            cageKey = try await http.loadKeys()
        }

        let privateKey = P256.KeyAgreement.PrivateKey()
        let derivedAesKey = try deriveSharedSecret(ecdh: privateKey, publicKey: cageKey.ecdhP256KeyUncompressed, ephemeralPublicKey: privateKey.publicKey)

        let isDebugMode = isInDebugMode ?? cageKey.isDebugMode

        return Crypto(
            ecdhTeamKey: Data(base64Encoded: cageKey.ecdhP256Key)!,
            ecdhPublicKey: privateKey.publicKey,
            derivedSecret: derivedAesKey,
            config: config.encryption,
            isDebug: isDebugMode
        )

    }
}


func deriveSharedSecret(ecdh: P256.KeyAgreement.PrivateKey, publicKey: String, ephemeralPublicKey: P256.KeyAgreement.PublicKey) throws -> Data {
    // Convert the public key from base64 string to Data
    guard let publicKeyData = Data(base64Encoded: publicKey) else {
        throw CryptoError.invalidPublicKey
    }

    // Import the public key as a CryptoKey object
    let importedPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: publicKeyData)

    // Perform the key agreement to derive the shared secret
    let sharedSecret = try ecdh.sharedSecretFromKeyAgreement(with: importedPublicKey)

    // Export the ephemeral public key and the secret key as Data
    let exportableEphemeralPublicKey = encodePublicKey(decompressedKeyData: ephemeralPublicKey.rawRepresentation)!


    let exportableSecret = sharedSecret.withUnsafeBytes { secretPtr in
        Data(secretPtr)
    }

    // Concatenate the secret key and the ephemeral public key
    var concatSecret = Data()
    concatSecret.append(exportableSecret)
    concatSecret.append(Data([0x00, 0x00, 0x00, 0x01]))
    concatSecret.append(exportableEphemeralPublicKey)

    // Hash the concatenated secret using SHA-256
    let hashDigest = SHA256.hash(data: concatSecret)

    return Data(hashDigest)
}

// Helper function to handle CryptoKit errors
enum CryptoError: Error {
    case invalidPublicKey
    case randomGenerationFailed
    case invalidPlaintext
}
