import Foundation

internal struct BytesHandler: DataHandler {

    let cipher: DataCipher

    func canEncrypt(data: Any) -> Bool {
        data is Data
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try cipher.encryptData(data: data as! Data)
    }
}
