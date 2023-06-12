import Foundation

enum EvervaultError: Error {
    case initializationError
}

extension EvervaultError: CustomStringConvertible {
    var description: String {
        switch self {
        case .initializationError:
            return "Evervault not initialized. Please use Evervault.shared.configure(teamId:appId:) to configure Everfault."
        }
    }
}
