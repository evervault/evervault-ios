import Foundation

internal func LocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, bundle: Bundle.module, comment: "")
}
