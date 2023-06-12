import SwiftUI

public struct PaymentCardInputStyleConfiguration {
//    struct CardImage<Content>: View where Content == Image {
//        init<Content>(content: Content) {
//            body = content
//        }
//
//        var body: Content
//    }
    public struct CardImage: View {
        public var body: Never
        public typealias Body = Never
    }

    public struct Field: View {
        public var body: Never
        public typealias Body = Never
    }

    public let cardImage: Image
    public let cardNumberField: AnyView
    public let expiryField: AnyView
    public let cvcField: AnyView
}
