import Foundation

internal func buildEncoder(curveValues: P256Constants) -> (_ decompressedKey: String) -> Data? {
    return { decompressedKey in
        let hexEncodedKey = ASN1.encode(
            "30",
            ASN1.encode(
                "30",
                ASN1.encode("06", "2A 86 48 CE 3D 02 01"), // 1.2.840.10045.2.1 ecPublicKey
                ASN1.encode(
                    "30",
                    ASN1.UINT("01"), // ECParameters Version
                    ASN1.encode(
                        "30",
                        ASN1.encode("06", "2A 86 48 CE 3D 01 01"), // X9.62 Prime Field
                        ASN1.UINT(curveValues.p) // curve p value
                    ),
                    ASN1.encode(
                        "30",
                        ASN1.encode("04", curveValues.a), // curve a value
                        ASN1.encode("04", curveValues.b), // curve b value
                        ASN1.BITSTR(curveValues.seed) // curve seed value
                    ),
                    ASN1.encode("04", curveValues.generator), // curve generate point in decompressed form
                    ASN1.UINT(curveValues.n), // curve n value
                    ASN1.UINT(curveValues.h) // curve h value
                )
            ),
            ASN1.BITSTR(decompressedKey) // decompressed public key
        )

        return hexStringToData(hex: hexEncodedKey)
    }
}

private func hexStringToData(hex: String) -> Data? {
    let length = hex.count / 2
    var result = Data(count: length)

    for i in 0..<length {
        let startIndex = hex.index(hex.startIndex, offsetBy: i * 2)
        let endIndex = hex.index(startIndex, offsetBy: 2)
        let substring = hex[startIndex..<endIndex]

        if let byte = UInt8(substring, radix: 16) {
            result[i] = byte
        } else {
            return nil // Return nil if the hex string is not valid
        }
    }

    return result
}


