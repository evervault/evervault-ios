import CryptoKit
import Foundation

internal struct Crypto {
    var ecdhTeamKey: Data
    var ecdhPublicKey: P256.KeyAgreement.PublicKey
    var derivedSecret: Data
    var config: EncryptionConfig
    var isDebug: Bool

    func encrypt(data: String) throws -> String {
        return try encryptString(string: data, dataType: "string")
    }

    private func encryptString(string: String, dataType: String) throws -> String {
        let keyIv = try generateBytes(byteLength: config.ivLength)

        let symmetricKey = SymmetricKey(data: derivedSecret)

        let sealedBox = try AES.GCM.seal(
                string.data(using: .utf8)!,
                using: symmetricKey,
                nonce: AES.GCM.Nonce(data: keyIv),
                authenticating: ecdhTeamKey
            )

        let encryptedBuffer = sealedBox.ciphertext

        return formatEncryptedData(
            evVersion: config.evVersion,
            datatype: dataType,
            keyIv: keyIv.base64EncodedString(),
            ecdhPublicKey: ecdhPublicKey,
            encryptedData: encryptedBuffer.base64EncodedString(),
            isDebug: isDebug
        )

    }
}

private func uint8ArrayToBase64String(_ uint8Array: Data) -> String {
    let data = Data(uint8Array)
    return data.base64EncodedString()
}

func formatEncryptedData(
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

func base64RemovePadding(_ str: String) -> String {
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
