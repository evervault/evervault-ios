import CryptoKit
import Foundation

internal struct Crypto: DataCipher {
    var ecdhTeamKey: Data
    var ecdhPublicKey: P256.KeyAgreement.PublicKey
    var derivedSecret: Data
    var config: EncryptionConfig
    var isDebug: Bool

    func encryptString(string: String, dataType: String) throws -> String {
        try encrypt(data: string.data(using: .utf8)!) { encryptedData, keyIv in
            formatEncryptedData(
                evVersion: config.evVersion,
                datatype: dataType,
                keyIv: keyIv.base64EncodedString(),
                ecdhPublicKey: ecdhPublicKey,
                encryptedData: encryptedData.base64EncodedString(),
                isDebug: isDebug
            )
        }
    }

    func encryptData(data: Data) throws -> Data {
        guard data.count <= config.maxFileSizeInBytes else {
            throw CryptoError.exceededMaxFileSizeError(maxFileSizeInMB: config.maxFileSizeInMB)
        }

        return try encrypt(data: data) { encryptedData, keyIv in
            formatFile(
                keyIv: keyIv,
                ecdhPublicKey: ecdhPublicKey,
                encryptedData: encryptedData
            )
        }
    }

    private func encrypt<T>(data: Data, format: (Data, Data) -> T) throws -> T {
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

        return format(combined, keyIv)
    }
}

private func uint8ArrayToBase64String(_ uint8Array: Data) -> String {
    let data = Data(uint8Array)
    return data.base64EncodedString()
}

private func formatEncryptedData(
    evVersion: String,
    datatype: String,
    keyIv: String,
    ecdhPublicKey: P256.KeyAgreement.PublicKey,
    encryptedData: String,
    isDebug: Bool
) -> String {
    let _evVersionPrefix = base64RemovePadding(
        evVersion.data(using: .utf8)!.base64EncodedString()
    )

    let exportableEcdhPublicKey = ecdhPublicKey.x963Representation
    let compressedKey = ecPointCompress(ecdhRawPublicKey: exportableEcdhPublicKey)

    return "ev:\(isDebug ? "debug:" : "")\(_evVersionPrefix)\(datatype != "string" ? ":\(datatype)" : ""):\(base64RemovePadding(keyIv)):\(base64RemovePadding(compressedKey.base64EncodedString())):\(base64RemovePadding(encryptedData)):$"
}

private func formatFile(
    keyIv: Data,
    ecdhPublicKey: P256.KeyAgreement.PublicKey,
    encryptedData: Data
) -> Data {
    let evEncryptedFileIdentifier: [UInt8] = [0x25, 0x45, 0x56, 0x45, 0x4e, 0x43]
    let versionNumber: [UInt8] = [0x03]
    let offsetToData: [UInt8] = [0x37, 0x00]
    let flags: [UInt8] = [0x00]

    let exportableEcdhPublicKey = ecdhPublicKey.x963Representation
    let compressedKey = ecPointCompress(ecdhRawPublicKey: exportableEcdhPublicKey)

    var fileContents = Data()
    fileContents.append(contentsOf: evEncryptedFileIdentifier)
    fileContents.append(contentsOf: versionNumber)
    fileContents.append(contentsOf: offsetToData)
    fileContents.append(contentsOf: compressedKey)
    fileContents.append(keyIv)
    fileContents.append(contentsOf: flags)
    fileContents.append(encryptedData)

    let crc32Hash = crc32(buffer: fileContents)
    var crc32HashBytes = Data()

    crc32HashBytes.append(UInt8((crc32Hash >> 0) & 0xFF))
    crc32HashBytes.append(UInt8((crc32Hash >> 8) & 0xFF))
    crc32HashBytes.append(UInt8((crc32Hash >> 16) & 0xFF))
    crc32HashBytes.append(UInt8((crc32Hash >> 24) & 0xFF))

    return fileContents + crc32HashBytes
}

private func base64RemovePadding(_ str: String) -> String {
    return str.replacingOccurrences(of: "={1,2}$", with: "", options: .regularExpression)
}


private func generateBytes(byteLength: Int) throws -> Data {
    var randomBytes = Data(count: byteLength)

    let result = SecRandomCopyBytes(kSecRandomDefault, byteLength, &randomBytes)
    guard result == errSecSuccess else {
        throw CryptoError.randomGenerationFailed
    }

    return randomBytes
}
