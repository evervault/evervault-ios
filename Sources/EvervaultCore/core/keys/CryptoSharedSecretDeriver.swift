import Foundation

import CryptoKit

internal struct CryptoSharedSecretDeriver: SharedSecretDeriver {
    func deriveSharedSecret(cageKey: CageKey) throws -> GeneratedSharedKey {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let derivedAesKey = try deriveSharedSecret(ecdh: privateKey, publicKey: cageKey.ecdhP256KeyUncompressed, ephemeralPublicKey: privateKey.publicKey)

        let publicKey = privateKey.publicKey
        let exportableEcdhPublicKey = publicKey.x963Representation
        let compressedKey = ecPointCompress(ecdhRawPublicKey: exportableEcdhPublicKey)

        return GeneratedSharedKey(
            generatedEcdhKey: compressedKey,
            sharedKey: derivedAesKey
        )
    }

    private func deriveSharedSecret(ecdh: P256.KeyAgreement.PrivateKey, publicKey: String, ephemeralPublicKey: P256.KeyAgreement.PublicKey) throws -> Data {
        // Convert the public key from base64 string to Data
        guard let publicKeyData = Data(base64Encoded: publicKey) else {
            throw CryptoError.invalidPublicKey
        }

        // Import the public key as a CryptoKey object
        let importedPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: publicKeyData)

        // Perform the key agreement to derive the shared secret
        let sharedSecret = try ecdh.sharedSecretFromKeyAgreement(with: importedPublicKey)

        // Export the ephemeral public key and the secret key as Data
        let exportableEphemeralPublicKey = encodePublicKey(decompressedKeyData: ephemeralPublicKey.x963Representation)!


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

}
