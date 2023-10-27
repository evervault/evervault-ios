import Foundation

internal protocol EncryptionService {
    func encryptString(string: String, dataType: DataType, role: String?) throws -> String
    func encryptData(data: Data) throws -> Data
}
