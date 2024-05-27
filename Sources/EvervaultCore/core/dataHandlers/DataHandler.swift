import Foundation

internal protocol DataHandlerContext {
    func encrypt(data: Any, role: String?) throws -> Any
}

internal protocol DataHandler {
    func canEncrypt(data: Any) -> Bool
    func encrypt(data: Any, role: String?, context: DataHandlerContext) throws -> Any
}
