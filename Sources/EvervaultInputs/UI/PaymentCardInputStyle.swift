import SwiftUI

public protocol PaymentCardInputStyle {
    associatedtype Body: View
    typealias Configuration = PaymentCardInputStyleConfiguration

    func makeBody(configuration: Self.Configuration) -> Self.Body
}
