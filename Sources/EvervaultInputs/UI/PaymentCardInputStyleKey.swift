import SwiftUI

/// The `EnvironmentKey` representing the `PaymentCardInputStyle`.
struct PaymentCardInputStyleKey: EnvironmentKey {
    /// The default value for the `PaymentCardInputStyleKey`.
    static var defaultValue: any PaymentCardInputStyle = .inline
}

/// A type-erased version of `PaymentCardInputStyle` allowing for any conforming style to be used.
struct AnyPaymentCardInputStyle: PaymentCardInputStyle {
    private var _makeBody: (Configuration) -> AnyView

    /// Initializes a new `AnyPaymentCardInputStyle`.
    ///
    /// - Parameter style: The `PaymentCardInputStyle` to type-erase.
    init<S: PaymentCardInputStyle>(style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    /// Creates a body view using the given configuration.
    ///
    /// - Parameter configuration: The configuration for the body view.
    /// - Returns: A `View` instance.
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

extension EnvironmentValues {
    /// An environment value that sets the style for a `PaymentCardInput` view.
    public var paymentCardInputStyle: any PaymentCardInputStyle {
        get { self[PaymentCardInputStyleKey.self] }
        set { self[PaymentCardInputStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for a `PaymentCardInput` view within the environment of `self`.
    ///
    /// - Parameter style: The style to set for `PaymentCardInput` views.
    /// - Returns: A view with the style for `PaymentCardInput` views set to `style`.
    public func paymentCardInputStyle<S: PaymentCardInputStyle>(_ style: S) -> some View {
        environment(\.paymentCardInputStyle, AnyPaymentCardInputStyle(style: style))
    }
}
