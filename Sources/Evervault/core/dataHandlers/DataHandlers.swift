import Foundation

internal struct DataHandlers {
    struct Context: DataHandlerContext {
        let dataHandlers: DataHandlers

        func encrypt(data: Any) throws -> Any {
            try dataHandlers.encrypt(data: data)
        }
    }

    let handlers: [DataHandler]

    init(cipher: DataCipher) {
        handlers = [
            StringHandler(cipher: cipher),
            BooleanHandler(cipher: cipher),
            NumberHandler(cipher: cipher),
            ArrayHandler(),
            DictionaryHandler(),
            BytesHandler(cipher: cipher)
        ]
    }

    func encrypt(data: Any) throws -> Any {
        guard let handler = handlers.first(where: { $0.canEncrypt(data: data) }) else {
            throw CryptoError.notPossibleToHandleDataType
        }
        let context = Context(dataHandlers: self)

        return try handler.encrypt(data: data, context: context)
    }

}
