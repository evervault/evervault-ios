import SwiftUI

struct PaymentCardInputStyleKey: EnvironmentKey {
    static var defaultValue: any PaymentCardInputStyle = .inline
}

struct AnyPaymentCardInputStyle: PaymentCardInputStyle {
    private var _makeBody: (Configuration) -> AnyView

    init<S: PaymentCardInputStyle>(style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

//struct CardStyleKey: EnvironmentKey {
//  static var defaultValue = AnyCardStyle(style: DefaultCardStyle())
//}

extension EnvironmentValues {
    public var paymentCardInputStyle: any PaymentCardInputStyle {
        get { self[PaymentCardInputStyleKey.self] }
        set { self[PaymentCardInputStyleKey.self] = newValue }
    }
}

extension View {
    public func paymentCardInputStyle<S: PaymentCardInputStyle>(_ style: S) -> some View {
        environment(\.paymentCardInputStyle, AnyPaymentCardInputStyle(style: style))
    }
}
