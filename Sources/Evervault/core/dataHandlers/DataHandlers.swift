import Foundation

internal struct DataHandlers {

    let handlers: [DataHandler]

    init(cipher: DataCipher) {
        handlers = [
            StringHandler(cipher: cipher),
            BooleanHandler(cipher: cipher),
            NumberHandler(cipher: cipher),
        ]
    }

    func encrypt(data: Any) throws -> String {
        guard let handler = handlers.first(where: { $0.canEncrypt(data: data) }) else {
            throw CryptoError.notPossibleToHandleDataType
        }

        return try handler.encrypt(data: data)
    }

}
