import Foundation

/// `PaymentCardData` represents the state of a payment card, including its validity and any associated errors.
///
/// - Note: This structure is `Equatable`, allowing it to be compared to other `PaymentCardData` structures.
public struct PaymentCardData: Equatable {
    /// The `PaymentCard` being validated.
    public var card: PaymentCard = PaymentCard()

    /// A boolean indicating whether the card is valid.
    public var isValid: Bool = false

    /// A boolean indicating whether the card is potentially valid. This might be `true` if the card passes initial validation but has not been thoroughly checked.
    public var isPotentiallyValid: Bool = true

    /// A boolean indicating whether the card data is empty.
    public var isEmpty: Bool = true

    /// If there's an error in the payment card, this holds the `PaymentCardError`.
    public var error: PaymentCardError? = nil

    /// Creates a new instance of `PaymentCardData`.
    public init() {}
}

/// `PaymentCard` represents a credit card with its essential information like card number, cvc, expiration month and year.
///
/// - Note: This structure is `Equatable`, allowing it to be compared to other `PaymentCard` structures.
public struct PaymentCard: Equatable {
    /// The type of credit card.
    public var type: CreditCardType? = nil

    /// The number of the credit card.
    public var number: String = ""
    
    /// The first 8 digits of the card number.
    public var bin: String = ""
    
    /// The last 4 digits of the card number.
    public var lastFour: String = ""

    /// The cvc (Card Verification Code) of the credit card.
    public var cvc: String = ""

    /// The expiration month of the credit card.
    public var expMonth: String = ""

    /// The expiration year of the credit card.
    public var expYear: String = ""

    /// Creates a new instance of `PaymentCard`.
    public init() {}
}

/// `PaymentCardError` represents different kinds of errors that can occur while validating a `PaymentCard`.
///
/// - Note: This enum is `Equatable`, allowing it to be compared to other `PaymentCardError` instances. It also conforms to `Error`, allowing it to be used in `throw` expressions.
public enum PaymentCardError: Equatable, Error {
    /// Error case indicating that the payment card number (Primary Account Number, or PAN) is invalid.
    case invalidPan

    /// Error case indicating that the expiration month of the payment card is invalid.
    case invalidMonth

    /// Error case indicating that encryption of the payment card details has failed.
    ///
    /// - Parameter message: A descriptive message providing more details about the error.
    case encryptionFailed(message: String)
}
