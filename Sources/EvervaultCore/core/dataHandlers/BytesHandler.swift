import Foundation

internal struct BytesHandler: DataHandler {

    let encryptionService: EncryptionService

    func canEncrypt(data: Any) -> Bool {
        data is Data
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try encryptionService.encryptData(data: data as! Data)
    }
}
