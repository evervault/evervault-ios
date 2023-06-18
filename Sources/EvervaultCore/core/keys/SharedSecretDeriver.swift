import Foundation

internal protocol SharedSecretDeriver {
    func deriveSharedSecret(cageKey: CageKey) throws -> GeneratedSharedKey
}
