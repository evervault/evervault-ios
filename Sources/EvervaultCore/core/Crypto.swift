import CryptoKit
import Foundation

internal struct Crypto: EncryptionService {

    let encryptionFormatter: EncryptionFormatter
    let dataCipher: DataCipher
    let config: EncryptionConfig

    func encryptString(string: String, dataType: DataType, role: String? = nil) throws -> String {
        var dataToEncrypt = Data()
        if let role = role {
            let timestamp = UInt32(Date().timeIntervalSince1970)
            let metadata = buildMetadata(timestamp: timestamp, role: role)
            
            let metadataLength = UInt16(metadata.count)
            var littleEndianValue = metadataLength.littleEndian
            let metadataOffset = Data(bytes: &littleEndianValue, count: MemoryLayout<UInt16>.size)
            
            dataToEncrypt.append(metadataOffset)
            dataToEncrypt.append(metadata)
        }
        dataToEncrypt.append(string.data(using: .utf8)!)
        return try encrypt(data: [dataToEncrypt]) { encryptedData, keyIv in
            encryptionFormatter.formatEncryptedData(
                dataType: dataType,
                keyIv: keyIv,
                encryptedData: encryptedData.base64EncodedString()
            )
        }
    }

    func encryptData(data: Data, role: String?) throws -> Data {
        guard data.count <= config.maxFileSizeInBytes else {
            throw CryptoError.exceededMaxFileSizeError(maxFileSizeInMB: config.maxFileSizeInMB)
        }
        
        var dataToEncrypt = [data];
        if let role = role {
            let timestamp = UInt32(Date().timeIntervalSince1970)
            let metadata = buildMetadata(timestamp: timestamp, role: role)
            dataToEncrypt.append(metadata)
        }
        
        return try encrypt(data: dataToEncrypt) { encryptedData, keyIv in
            encryptionFormatter.formatFile(
                keyIv: keyIv,
                encryptedData: encryptedData
            )
        }
    }

    private func encrypt<T>(data: Array<Data>, format: (Data, Data) -> T) throws -> T {
        let encryptedData = try dataCipher.encrypt(data: data[0])
        return format(encryptedData.data, encryptedData.keyIv)
    }
}

private func uint8ArrayToBase64String(_ uint8Array: Data) -> String {
    let data = Data(uint8Array)
    return data.base64EncodedString()
}

private func buildMetadata(timestamp: UInt32, role: String? = nil) -> Data {
    var buffer = Data()

    let initialByte: UInt8 = role?.isEmpty ?? true ? 0x82 : 0x83 // 0x80 ORed with 2 or 3 based on role's presence
    buffer.append(initialByte)

    if let role = role, !role.isEmpty {
        // `dr` (data role) => role_name
        buffer.append(0xA2) // Fixed string of length 2
        buffer.append(contentsOf: "dr".utf8) // `dr`

        let roleLength = UInt8(0xA0 | role.utf8.count) // 0xA0 ORed with the length of the role
        buffer.append(roleLength) // Length byte
        buffer.append(contentsOf: role.utf8) // role name itself
    }

    // "eo" (encryption origin) => 13 (iOS SDK)
    buffer.append(0xA2) // Fixed string of length 2
    buffer.append(contentsOf: "eo".utf8) // `eo`
    buffer.append(13) // Value 13

    // "et" (encryption timestamp) => current time
    buffer.append(0xA2) // Fixed string of length 2
    buffer.append(contentsOf: "et".utf8) // `et`

    var bigEndianTime = timestamp.bigEndian // convert to big-endian format (network byte order)
    let timeData = Data(bytes: &bigEndianTime, count: MemoryLayout.size(ofValue: bigEndianTime))
    buffer.append(0xCE) // Binary representation for a 4-byte unsigned integer (uint 32)
    buffer.append(timeData) // epoch time

    return buffer
}
