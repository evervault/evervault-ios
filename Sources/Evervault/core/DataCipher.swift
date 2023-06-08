import Foundation

internal protocol DataCipher {
    func encryptString(string: String, dataType: String) throws -> String
}
