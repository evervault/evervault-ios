import CryptoKit
import Foundation

internal struct Crypto: EncryptionService {

    let encryptionFormatter: EncryptionFormatter
    let dataCipher: DataCipher
    let config: EncryptionConfig

    func encryptString(string: String, dataType: DataType) throws -> String {
        try encrypt(data: string.data(using: .utf8)!) { encryptedData, keyIv in
            encryptionFormatter.formatEncryptedData(
                dataType: dataType,
                keyIv: keyIv,
                encryptedData: encryptedData.base64EncodedString()
            )
        }
    }

    func encryptData(data: Data) throws -> Data {
        guard data.count <= config.maxFileSizeInBytes else {
            throw CryptoError.exceededMaxFileSizeError(maxFileSizeInMB: config.maxFileSizeInMB)
        }

        return try encrypt(data: data) { encryptedData, keyIv in
            encryptionFormatter.formatFile(
                keyIv: keyIv,
                encryptedData: encryptedData
            )
        }
    }

    private func encrypt<T>(data: Data, format: (Data, Data) -> T) throws -> T {
        let encryptedData = try dataCipher.encrypt(data: data)
        return format(encryptedData.data, encryptedData.keyIv)
    }
}

private func uint8ArrayToBase64String(_ uint8Array: Data) -> String {
    let data = Data(uint8Array)
    return data.base64EncodedString()
}
