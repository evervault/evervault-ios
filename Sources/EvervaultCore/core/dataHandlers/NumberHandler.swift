import Foundation

internal struct NumberHandler: DataHandler {

    let encryptionService: EncryptionService

    func canEncrypt(data: Any) -> Bool {
        data is any Numeric
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try encryptionService.encryptString(string: String(describing: data), dataType: .number)
    }
}
