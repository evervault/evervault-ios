import Foundation

internal struct DictionaryHandler: DataHandler {

    func canEncrypt(data: Any) -> Bool {
        data is Dictionary<AnyHashable, Any>
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try (data as! Dictionary<AnyHashable, Any>).mapValues {
            try context.encrypt(data: $0)
        }
    }
}
