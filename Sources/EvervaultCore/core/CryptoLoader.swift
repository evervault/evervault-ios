import CryptoKit
import Foundation

internal actor CryptoLoader {

    private var activeTask: Task<Crypto, Error>?
    private var cachedKey: Crypto?

    private let config: Config
    private let http: Http
    private let sharedSecretDeriver: SharedSecretDeriver
    private let dataCipherFactory: DataCipherFactory
    private let isInDebugMode: Bool?

    init(config: Config, http: Http, sharedSecretDeriver: SharedSecretDeriver, dataCipherFactory: DataCipherFactory, isInDebugMode: Bool?) {
        self.config = config
        self.http = http
        self.sharedSecretDeriver = sharedSecretDeriver
        self.dataCipherFactory = dataCipherFactory
        self.isInDebugMode = isInDebugMode
    }

    func loadCipher() async throws -> EncryptionService {
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

        let generated = try sharedSecretDeriver.deriveSharedSecret(cageKey: cageKey)
        let teamKeyPublic = Data(base64Encoded: cageKey.ecdhP256Key)!

        let sharedKey = generated.sharedKey
        let generatedEcdhKey = generated.generatedEcdhKey

        let isDebugMode = isInDebugMode ?? cageKey.isDebugMode

        return Crypto(
            encryptionFormatter: R1StdEncryptionFormatter(
                evVersion: config.encryption.evVersion,
                publicKey: generatedEcdhKey,
                isDebug: isDebugMode
            ),
            dataCipher: dataCipherFactory.createCipher(
                ecdhTeamKey: teamKeyPublic,
                derivedSecret: sharedKey,
                config: config.encryption
            ),
            config: config.encryption
        )

    }
}



// Helper function to handle CryptoKit errors
enum CryptoError: Error {
    case invalidPublicKey
    case randomGenerationFailed
    case invalidPlaintext
    case notPossibleToHandleDataType
    case exceededMaxFileSizeError(maxFileSizeInMB: Int)
    case encryptionFailed
}
