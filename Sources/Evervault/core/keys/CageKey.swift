import Foundation

internal struct CageKey {
    let ecdhP256Key: String
    let ecdhP256KeyUncompressed: String
    var isDebugMode: Bool

    init(ecdhP256Key: String, ecdhP256KeyUncompressed: String, isDebugMode: Bool = false) {
        self.ecdhP256Key = ecdhP256Key
        self.ecdhP256KeyUncompressed = ecdhP256KeyUncompressed
        self.isDebugMode = isDebugMode
    }

    init(publicKey: String, isDebugMode: Bool = false) {

        let keyData = Data(base64Encoded: publicKey.data(using: .utf8)!)!
        let compressedKey = ecPointCompress(ecdhRawPublicKey: keyData)
        let compressedKeyString = compressedKey.base64EncodedString()

        self.ecdhP256Key = compressedKeyString
        self.ecdhP256KeyUncompressed = publicKey
        self.isDebugMode = isDebugMode
    }

}
