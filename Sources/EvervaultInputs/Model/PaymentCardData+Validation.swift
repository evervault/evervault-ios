import Foundation

internal extension PaymentCardData {

    var expiry: String {
        return "\(card.expMonth)/\(card.expYear)"
    }

    init(number: String, cvc: String, expiry: String) {
        let validator = CreditCardValidator(number)
        self.card.type = validator.predictedType

        var number = validator.string
        if let type = self.card.type {
            number = String(number.prefix(type.validNumberLength.last!))
        }

        let formattedNumber = CreditCardFormatter.formatCardNumber(number)

        self.card.number = formattedNumber
        self.card.cvc = String(cvc.numbers.prefix(CreditCardValidator.maxCvcLength(for: self.card.type)))

        let expiryParts = expiry.split(separator: "/")
        self.card.expMonth = expiryParts.count > 0 ? String(expiryParts[0]).numbers : ""
        self.card.expYear = expiryParts.count > 1 ? String(expiryParts[1]).numbers : ""

        let monthNumber = Int(self.card.expMonth)
        let yearNumber = Int(self.card.expYear)

        let actualType = validator.actualType
        self.isValid = actualType != nil && validator.isValid && CreditCardValidator.isValidCvc(cvc: cvc, type: actualType!) && monthNumber != nil && (1...12).contains(monthNumber!) && yearNumber != nil
        self.isPotentiallyValid = validator.isPotentiallyValid && (monthNumber == nil || (1...12).contains(monthNumber!))
        self.isEmpty = number.isEmpty

        if self.isPotentiallyValid {
            self.error = nil
        } else {
            if !validator.isPotentiallyValid {
                self.error = PaymentCardError(type: "invalid_pan", message: "The credit card number you entered was invalid")
            } else if monthNumber != nil && !(1...12).contains(monthNumber!) {
                self.error = PaymentCardError(type: "invalid_month", message: "The month number you entered was invalid")
            }
        }

    }

    mutating func updateNumber(_ number: String) {
        self = .init(number: number, cvc: self.card.cvc, expiry: self.expiry)
    }

    mutating func updateCvc(_ cvc: String) {
        self = .init(number: self.card.number, cvc: cvc, expiry: self.expiry)
    }

    mutating func updateExpiry(_ expiry: String) {
        self = .init(number: self.card.number, cvc: self.card.cvc, expiry: expiry)
    }
}
