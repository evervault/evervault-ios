import Foundation

internal struct StringHandler: DataHandler {

    let encryptionService: EncryptionService

    func canEncrypt(data: Any) -> Bool {
        data is String
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try encryptionService.encryptString(string: data as! String, dataType: .string)
    }
}
