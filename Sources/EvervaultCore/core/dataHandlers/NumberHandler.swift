import Foundation

internal struct NumberHandler: DataHandler {

    let encryptionService: EncryptionService

    func canEncrypt(data: Any) -> Bool {
        print(data)
        return data is Int ||
               data is Int8 ||
               data is Int16 ||
               data is Int32 ||
               data is Int64 ||
               data is UInt ||
               data is UInt8 ||
               data is UInt16 ||
               data is UInt32 ||
               data is UInt64 ||
               data is Float ||
               data is Double ||
               data is CGFloat ||
               data is Decimal ||
               data is NSNumber &&
               !(data is Bool)
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try encryptionService.encryptString(string: String(describing: data), dataType: .number)
    }
}
