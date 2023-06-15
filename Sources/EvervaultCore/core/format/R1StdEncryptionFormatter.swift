
struct R1StdEncryptionFormatter: EncryptionFormatter {

    let evVersion: String
    let isDebug: Bool

    func formatEncryptedData(datatype: String, keyIv: String, publicKey: String, encryptedData: String) -> String {

        let evVersionPrefix = evVersion.data(using: .utf8)!.base64EncodedString().paddingRemoved

        return "ev:\(isDebug ? "debug:" : "")\(evVersionPrefix)\(datatype != "string" ? ":\(datatype)" : ""):\(keyIv.paddingRemoved):\(publicKey.paddingRemoved):\(encryptedData.paddingRemoved):$"
    }
}

extension String {
    fileprivate var paddingRemoved: String {
        var i = count - 1

        while i > 0 {
            if self[index(startIndex, offsetBy: i)] != "=" {
                break
            }
            i -= 1
        }

        return String(self[..<index(startIndex, offsetBy: i + 1)])
    }

}
