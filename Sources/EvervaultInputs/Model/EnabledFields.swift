import Foundation

public struct EnabledFields: Equatable {
    var isCardNumberEnabled: Bool = true
    var isExpiryEnabled: Bool = true
    var isCVCEnabled: Bool = true

    public init(isCardNumberEnabled: Bool = true, isExpiryEnabled: Bool = true, isCVCEnabled: Bool = true) {
        self.isCardNumberEnabled = isCardNumberEnabled
        self.isExpiryEnabled = isExpiryEnabled
        self.isCVCEnabled = isCVCEnabled
    }
}
