import Foundation

internal struct StringHandler: DataHandler {

    let encryptionService: EncryptionService

    func canEncrypt(data: Any) -> Bool {
        data is String
    }

    func encrypt(data: Any, role: String?, context: DataHandlerContext) throws -> Any {
        try encryptionService.encryptString(string: data as! String, role: role, dataType: .string)
    }
}
