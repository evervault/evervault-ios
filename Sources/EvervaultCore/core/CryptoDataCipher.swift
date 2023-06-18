import CryptoKit
import Foundation

internal struct CryptoDataCipher: DataCipher {

    fileprivate let ecdhTeamKey: Data
    fileprivate let derivedSecret: Data
    fileprivate let config: EncryptionConfig

    func encrypt(data: Data) throws -> EncryptedData {
        let keyIv = try generateBytes(byteLength: config.ivLength)

        let symmetricKey = SymmetricKey(data: derivedSecret)

        let sealedBox = try AES.GCM.seal(
            data,
            using: symmetricKey,
            nonce: AES.GCM.Nonce(data: keyIv),
            authenticating: ecdhTeamKey
        )

        let encryptedBuffer = sealedBox.ciphertext
        let authenticationTag = sealedBox.tag

        let combined = encryptedBuffer + authenticationTag

        return EncryptedData(data: combined, keyIv: keyIv)
    }
}

internal struct CryptoDataCipherFactory: DataCipherFactory {
    func createCipher(ecdhTeamKey: Data, derivedSecret: Data, config: EncryptionConfig) -> DataCipher {
        return CryptoDataCipher(ecdhTeamKey: ecdhTeamKey, derivedSecret: derivedSecret, config: config)
    }
}


private func generateBytes(byteLength: Int) throws -> Data {
    var randomBytes = Data(count: byteLength)

    let result = SecRandomCopyBytes(kSecRandomDefault, byteLength, &randomBytes)
    guard result == errSecSuccess else {
        throw CryptoError.randomGenerationFailed
    }

    return randomBytes
}
