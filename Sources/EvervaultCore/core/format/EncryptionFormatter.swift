import CryptoKit

internal protocol EncryptionFormatter {
    func formatEncryptedData(
        datatype: String,
        keyIv: String,
        publicKey: String,
        encryptedData: String
    ) -> String
}

extension EncryptionFormatter {

    func formatEncryptedData(
        datatype: String,
        keyIv: String,
        publicKey: P256.KeyAgreement.PublicKey,
        encryptedData: String
    )  -> String {
        let exportableEcdhPublicKey = publicKey.x963Representation
        let compressedKey = ecPointCompress(ecdhRawPublicKey: exportableEcdhPublicKey)

        return formatEncryptedData(datatype: datatype, keyIv: keyIv, publicKey: compressedKey.base64EncodedString(), encryptedData: encryptedData)
    }
}
