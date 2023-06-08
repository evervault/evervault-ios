import Foundation

internal protocol DataHandler {
    func canEncrypt(data: Any) -> Bool
    func encrypt(data: Any) throws -> String
}
