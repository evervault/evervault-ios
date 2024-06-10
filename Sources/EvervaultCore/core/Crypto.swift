import CryptoKit
import Foundation

internal struct Crypto: EncryptionService {

    let encryptionFormatter: EncryptionFormatter
    let dataCipher: DataCipher
    let config: EncryptionConfig

    func encryptString(string: String, role: String?, dataType: DataType) throws -> String {
        try encrypt(dataType: dataType, data: string.data(using: .utf8)!, role: role) { encryptedData, keyIv in
            encryptionFormatter.formatEncryptedData(
                dataType: dataType,
                keyIv: keyIv,
                encryptedData: encryptedData.base64EncodedString()
            )
        }
    }

    func encryptData(data: Data, role: String?) throws -> Data {
        if role != Optional.none {
            throw CryptoError.dataRolesNotSupportedForFiles
        }
        
        guard data.count <= config.maxFileSizeInBytes else {
            throw CryptoError.exceededMaxFileSizeError(maxFileSizeInMB: config.maxFileSizeInMB)
        }

        return try encrypt(dataType: Optional.none, data: data, role: Optional.none) { encryptedData, keyIv in
            encryptionFormatter.formatFile(
                keyIv: keyIv,
                encryptedData: encryptedData
            )
        }
    }

    private func encrypt<T>(dataType: DataType?, data: Data, role: String?, format: (Data, Data) -> T) throws -> T {
        let encryptedData = try dataCipher.encrypt(data: data, role: role, dataType: dataType)
        return format(encryptedData.data, encryptedData.keyIv)
    }
}

private func uint8ArrayToBase64String(_ uint8Array: Data) -> String {
    let data = Data(uint8Array)
    return data.base64EncodedString()
}
