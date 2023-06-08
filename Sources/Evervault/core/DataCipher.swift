import Foundation

internal protocol DataCipher {
    func encryptString(string: String, dataType: String) throws -> String
    func encryptData(data: Data) throws -> Data
}
