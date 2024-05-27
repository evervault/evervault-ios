import Foundation

internal protocol DataCipher {
    func encrypt(data: Data, role: String?, dataType: DataType?) throws -> EncryptedData

}

protocol DataCipherFactory {
    func createCipher(ecdhTeamKey: Data, derivedSecret: Data, config: EncryptionConfig, isDebug: Bool, ephemeralPublicKey: Data) -> DataCipher
}
