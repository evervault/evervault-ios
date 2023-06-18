import Foundation

internal protocol DataCipher {
    func encrypt(data: Data) throws -> EncryptedData

}

protocol DataCipherFactory {
    func createCipher(ecdhTeamKey: Data, derivedSecret: Data, config: EncryptionConfig) -> DataCipher
}
