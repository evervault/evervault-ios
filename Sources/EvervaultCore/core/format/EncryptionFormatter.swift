import CryptoKit
import Foundation

internal protocol EncryptionFormatter {
    func formatEncryptedData(
        dataType: DataType,
        keyIv: Data,
        encryptedData: String
    ) -> String

    func formatFile(
        keyIv: Data,
        encryptedData: Data
    ) -> Data
}
