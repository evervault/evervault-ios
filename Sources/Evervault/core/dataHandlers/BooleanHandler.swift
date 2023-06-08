import Foundation

internal struct BooleanHandler: DataHandler {

    let cipher: DataCipher

    func canEncrypt(data: Any) -> Bool {
        data is Bool
    }

    func encrypt(data: Any, context: DataHandlerContext) throws -> Any {
        try cipher.encryptString(string: String(data as! Bool), dataType: "boolean")
    }
}