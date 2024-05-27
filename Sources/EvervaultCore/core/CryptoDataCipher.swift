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
    
    private func createV2Aad(dataType: DataType, isDebug: Bool, ecdhPublicKey: P256.KeyAgreement.PublicKey, ecdhTeamKey: Data) async throws -> Data {
        var dataTypeNumber = 0 // Default to String

        switch dataType {
        case .number:
            dataTypeNumber = 1
        case .boolean:
            dataTypeNumber = 2
        default:
            break
        }

        let versionNumber = 1

        let exportableEcdhPublicKeyUncompressed = ecdhPublicKey.rawRepresentation

        let exportableEcdhPublicKey = ecPointCompress(ecdhRawPublicKey: exportableEcdhPublicKeyUncompressed)

        let configByteSize = 1
        let totalSize = configByteSize + exportableEcdhPublicKey.count + ecdhTeamKey.count
        var aad = Data(count: totalSize)

        // Set the configuration byte
        let b = isDebug ? 0x80 : 0x00 | (dataTypeNumber << 4) | versionNumber
        aad[0] = UInt8(b)

        aad.replaceSubrange(configByteSize..<configByteSize + exportableEcdhPublicKey.count, with: exportableEcdhPublicKey)

        aad.replaceSubrange(configByteSize + exportableEcdhPublicKey.count..<totalSize, with: ecdhTeamKey)

        return aad
    }
}

internal struct CryptoDataCipherFactory: DataCipherFactory {
    func createCipher(ecdhTeamKey: Data, derivedSecret: Data, config: EncryptionConfig) -> DataCipher {
        return CryptoDataCipher(ecdhTeamKey: ecdhTeamKey, derivedSecret: derivedSecret, config: config)
    }
}

private func ecPointCompress(_ rawKey: Data) -> Data {
    // Assuming P-256 curve
    var compressedKey = Data()
    let yCoord = rawKey.suffix(32)
    if yCoord.last! % 2 == 0 {
        compressedKey.append(0x02)
    } else {
        compressedKey.append(0x03)
    }
    compressedKey.append(rawKey.prefix(32))
    return compressedKey
}

private func generateBytes(byteLength: Int) throws -> Data {
    var randomBytes = Data(count: byteLength)

    let result = SecRandomCopyBytes(kSecRandomDefault, byteLength, &randomBytes)
    guard result == errSecSuccess else {
        throw CryptoError.randomGenerationFailed
    }

    return randomBytes
}
