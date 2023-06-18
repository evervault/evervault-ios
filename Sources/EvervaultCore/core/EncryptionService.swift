
import Foundation

internal protocol EncryptionService {
    func encryptString(string: String, dataType: DataType) throws -> String
    func encryptData(data: Data) throws -> Data
}
