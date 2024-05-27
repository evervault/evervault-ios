import Foundation

struct R1StdEncryptionFormatter: EncryptionFormatter {

    let evVersion: String
    let publicKey: Data
    let isDebug: Bool

    func formatEncryptedData(dataType: DataType, keyIv: Data, encryptedData: String) -> String {
        return "ev:\(isDebug ? "debug:" : "")\(evVersion)\(dataType != .string ? ":\(dataType.rawValue)" : ""):\(keyIv.base64EncodedString().paddingRemoved):\(publicKey.base64EncodedString().paddingRemoved):\(encryptedData.paddingRemoved):$"
    }

    func formatFile(keyIv: Data, encryptedData: Data) -> Data {
        let evEncryptedFileIdentifier: [UInt8] = [0x25, 0x45, 0x56, 0x45, 0x4e, 0x43]
        let versionNumber: [UInt8] = [0x03]
        let offsetToData: [UInt8] = [0x37, 0x00]
        let flags: [UInt8] = [0x00]

        var fileContents = Data()
        fileContents.append(contentsOf: evEncryptedFileIdentifier)
        fileContents.append(contentsOf: versionNumber)
        fileContents.append(contentsOf: offsetToData)
        fileContents.append(contentsOf: publicKey)
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
