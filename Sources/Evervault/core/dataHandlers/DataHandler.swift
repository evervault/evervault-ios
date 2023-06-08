import Foundation

internal protocol DataHandlerContext {
    func encrypt(data: Any) throws -> Any
}

internal protocol DataHandler {

    func canEncrypt(data: Any) -> Bool
    func encrypt(data: Any, context: DataHandlerContext) throws -> Any
}
