import CryptoKit
import Foundation

internal struct CryptoDataCipher: DataCipher {

    fileprivate let ecdhTeamKey: Data
    fileprivate let derivedSecret: Data
    fileprivate let config: EncryptionConfig
    fileprivate let isDebug: Bool
    fileprivate let ephemeralPublicKey: Data

    func encrypt(data: Data, role: String?, dataType: DataType?) throws -> EncryptedData {
        let keyIv = try generateBytes(byteLength: config.ivLength)

        let symmetricKey = SymmetricKey(data: derivedSecret)
        
        var mutableData = Data()
        
        // If dataType is none then we're dealing with file encryption
        if dataType != Optional.none {
            let timestamp = UInt32(Date().timeIntervalSince1970)
            let metadata = buildEncodedMetadata(role: role, encryptionTimestamp: timestamp)
            var size = UInt16(metadata.count).littleEndian
            let sizeBytes = withUnsafeBytes(of: &size) { Data($0) }
            mutableData.append(sizeBytes)
            mutableData.append(metadata)
            mutableData.append(data)
        } else {
            mutableData = data
        }
        
        let aad = dataType != Optional.none ? try createV2Aad(dataType: dataType!, isDebug: isDebug, ecdhPublicKey: ephemeralPublicKey, ecdhTeamKey: ecdhTeamKey) : ecdhTeamKey

        let sealedBox = try AES.GCM.seal(
            mutableData,
            using: symmetricKey,
            nonce: AES.GCM.Nonce(data: keyIv),
            authenticating: aad
        )

        let encryptedBuffer = sealedBox.ciphertext
        let authenticationTag = sealedBox.tag

        let combined = encryptedBuffer + authenticationTag

        return EncryptedData(data: combined, keyIv: keyIv)
    }
    
    private func createV2Aad(dataType: DataType, isDebug: Bool, ecdhPublicKey: Data, ecdhTeamKey: Data) throws -> Data {
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

        let configByteSize = 1
        let totalSize = configByteSize + ecdhPublicKey.count + ecdhTeamKey.count
        var aad = Data(count: totalSize)

        // Set the configuration byte
        let b = isDebug ? 0x80 : 0x00 | (dataTypeNumber << 4) | versionNumber
        aad[0] = UInt8(b)

        aad.replaceSubrange(configByteSize..<configByteSize + ecdhPublicKey.count, with: ecdhPublicKey)

        aad.replaceSubrange(configByteSize + ecdhPublicKey.count..<totalSize, with: ecdhTeamKey)

        return aad
    }
}

internal struct CryptoDataCipherFactory: DataCipherFactory {
    func createCipher(ecdhTeamKey: Data, derivedSecret: Data, config: EncryptionConfig, isDebug: Bool, ephemeralPublicKey: Data) -> DataCipher {
        return CryptoDataCipher(ecdhTeamKey: ecdhTeamKey, derivedSecret: derivedSecret, config: config, isDebug: isDebug, ephemeralPublicKey: ephemeralPublicKey)
    }
}

private func buildEncodedMetadata(role: String?, encryptionTimestamp: UInt32) -> Data {
    var buffer = [UInt8]()

    // Binary representation of a fixed map with 2 or 3 items, followed by the key-value pairs.
    buffer.append(0x80 | (role == nil ? 2 : 3))

    if let role = role {
        // `dr` (data role) => role_name
        // Binary representation for a fixed string of length 2, followed by `dr`
        buffer.append(0xa2)
        buffer.append(contentsOf: "dr".utf8)

        // Binary representation for a fixed string of role name length, followed by the role name itself.
        buffer.append(0xa0 | UInt8(role.count))
        buffer.append(contentsOf: role.utf8)
    }

    // "eo" (encryption origin) => 13 (IOS SDK)
    // Binary representation for a fixed string of length 2, followed by `eo`
    buffer.append(0xa2)
    buffer.append(contentsOf: "eo".utf8)

    // Binary representation for the integer 13
    buffer.append(13)

    // "et" (encryption timestamp) => current time
    // Binary representation for a fixed string of length 2, followed by `et`
    buffer.append(0xa2)
    buffer.append(contentsOf: "et".utf8)

    // Binary representation for a 4-byte unsigned integer (uint 32), followed by the epoch time
    buffer.append(0xce)
    buffer.append(UInt8((encryptionTimestamp >> 24) & 0xff))
    buffer.append(UInt8((encryptionTimestamp >> 16) & 0xff))
    buffer.append(UInt8((encryptionTimestamp >> 8) & 0xff))
    buffer.append(UInt8(encryptionTimestamp & 0xff))

    return Data(buffer)
}

private func generateBytes(byteLength: Int) throws -> Data {
    var randomBytes = Data(count: byteLength)

    let result = SecRandomCopyBytes(kSecRandomDefault, byteLength, &randomBytes)
    guard result == errSecSuccess else {
        throw CryptoError.randomGenerationFailed
    }

    return randomBytes
}
