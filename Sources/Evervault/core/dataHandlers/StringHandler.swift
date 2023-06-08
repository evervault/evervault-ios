import Foundation

internal struct StringHandler: DataHandler {

    let cipher: DataCipher

    func canEncrypt(data: Any) -> Bool {
        data is String
    }

    func encrypt(data: Any) throws -> String {
        try cipher.encryptString(string: data as! String, dataType: "string")
    }
}
