import SwiftUI

/// A protocol defining a style for the `PaymentCardInput` view.
public protocol PaymentCardInputStyle {
    /// The `View` type that the style's `makeBody(configuration:)` function will return.
    associatedtype Body: View

    /// The `Configuration` type that the style's `makeBody(configuration:)` function accepts.
    typealias Configuration = PaymentCardInputStyleConfiguration

    /// Function to create a body view using the given configuration.
    ///
    /// - Parameter configuration: The configuration for the body view.
    /// - Returns: A `View` instance.
    func makeBody(configuration: Self.Configuration) -> Self.Body
}
