import Foundation

internal struct DataHandlers {
    struct Context: DataHandlerContext {
        let dataHandlers: DataHandlers

        func encrypt(data: Any, role: String?) throws -> Any {
            try dataHandlers.encrypt(data: data, role: role)
        }
    }

    let handlers: [DataHandler]

    init(encryptionService: EncryptionService) {
        handlers = [
            StringHandler(encryptionService: encryptionService),
            BooleanHandler(encryptionService: encryptionService),
            NumberHandler(encryptionService: encryptionService),
            ArrayHandler(),
            DictionaryHandler(),
            BytesHandler(encryptionService: encryptionService)
        ]
    }

    func encrypt(data: Any, role: String?) throws -> Any {
        guard let handler = handlers.first(where: { $0.canEncrypt(data: data) }) else {
            throw CryptoError.notPossibleToHandleDataType
        }
        let context = Context(dataHandlers: self)

        return try handler.encrypt(data: data, role: role, context: context)
    }

}
