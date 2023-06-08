import Foundation

internal struct NumberHandler: DataHandler {

    let cipher: DataCipher

    func canEncrypt(data: Any) -> Bool {
        data is any Numeric
    }

    func encrypt(data: Any) throws -> String {
        try cipher.encryptString(string: String(describing: data), dataType: "number")
    }
}
