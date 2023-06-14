import SwiftUI

/// A struct defining a configuration for the `PaymentCardInputStyle` protocol.
public struct PaymentCardInputStyleConfiguration {
    /// The card image `View`.
    public struct CardImage: View {
        public var body: Never
        public typealias Body = Never
    }

    /// The text field `View`.
    public struct Field: View {
        public var body: Never
        public typealias Body = Never
    }

    /// The card image.
    public let cardImage: Image

    /// The card number field.
    public let cardNumberField: AnyView

    /// The expiry date field.
    public let expiryField: AnyView

    /// The CVC field.
    public let cvcField: AnyView
}
