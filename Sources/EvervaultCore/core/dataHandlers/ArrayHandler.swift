import Foundation

internal struct ArrayHandler: DataHandler {

    func canEncrypt(data: Any) -> Bool {
        data is Array<Any>
    }

    func encrypt(data: Any, role: String?, context: DataHandlerContext) throws -> Any {
        try (data as! Array<Any>).map {
            try context.encrypt(data: $0, role: role)
        }
    }
}
