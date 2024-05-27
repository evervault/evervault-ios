import Foundation

internal protocol EncryptionService {
    func encryptString(string: String, role: String?, dataType: DataType) throws -> String
    func encryptData(data: Data, role: String?) throws -> Data
}
