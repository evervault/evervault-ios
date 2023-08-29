import Foundation

enum EvervaultError: Error {
    case initializationError
    case unsupportedEncryptedTypeError
    case serverError
    case invalidCast
}

extension EvervaultError: CustomStringConvertible {
    var description: String {
        switch self {
        case .initializationError:
            return "Evervault not initialized. Please use Evervault.shared.configure(teamId:appId:) to configure Everfault."
        case .unsupportedEncryptedTypeError:
            return "Only values of type String, [String], and [String: Any] can be decrypted. Please ensure your input matches one of these types."
        case .invalidCast:
            return "Decrypted data couldn't be casted to the expected type."
        case .serverError:
            return "A transient server error occurred. Please try again. If you continue to experience problems, please contact support@evervault.com."
        }
    }
}
