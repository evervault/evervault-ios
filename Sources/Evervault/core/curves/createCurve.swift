import Foundation

func createCurve(curveValues: P256Constants) -> (_ decompressedKey: Data) -> Data? {
    let asn1Encoder = buildEncoder(curveValues: curveValues)

    return { decompressedKeyData in
        let hexEncodedKey = dataToHexString(data: decompressedKeyData)
        return asn1Encoder(hexEncodedKey)
    }
}

func dataToHexString(data: Data) -> String {
    let hexStrings = data.map { String(format: "%02x", $0) }
    return hexStrings.joined()
}
