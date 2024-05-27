import Foundation

internal struct BooleanHandler: DataHandler {

    let encryptionService: EncryptionService

    func canEncrypt(data: Any) -> Bool {
        data is Bool
    }

    func encrypt(data: Any, role: String?, context: DataHandlerContext) throws -> Any {
        try encryptionService.encryptString(string: String(data as! Bool), role: role, dataType: .boolean)
    }
}
