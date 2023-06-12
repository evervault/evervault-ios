import Foundation

public struct PaymentCardData: Equatable {
    public var card: PaymentCard = PaymentCard()
    public var isValid: Bool = false
    public var isPotentiallyValid: Bool = true
    public var isEmpty: Bool = true
    public var error: PaymentCardError? = nil

    public init() {}
}

public struct PaymentCard: Equatable {
    public var type: CreditCardType? = nil
    public var number: String = ""
    public var cvc: String = ""
    public var expMonth: String = ""
    public var expYear: String = ""

    public init() {}
}

public struct PaymentCardError: Equatable {
    public var type: String
    public var message: String
}
