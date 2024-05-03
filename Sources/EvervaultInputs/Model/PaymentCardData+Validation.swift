import Foundation

internal extension PaymentCardData {

    var expiry: String {
        return "\(card.expMonth)/\(card.expYear)"
    }

    init(number: String, cvc: String, expiry: String, config: PaymentCardValidationConfig) {
        let validator = CreditCardValidator(number)
        self.card.type = validator.predictedType
        
        if config.validateCardNumber {
            var number = validator.string
            if let type = self.card.type {
                number = String(number.prefix(type.validNumberLength.last!))
            }
            let formattedNumber = CreditCardFormatter.formatCardNumber(number)

            self.card.number = formattedNumber
            if validator.isValid {
                self.card.bin = (self.card.type == .amex) ? String(number.prefix(6)) : String(number.prefix(8))
                self.card.lastFour = String(number.suffix(4))
            }
        }
        
        if config.validateCVC {
            self.card.cvc = String(cvc.numbers.prefix(CreditCardValidator.maxCvcLength(for: self.card.type)))
        }

        if config.validateExpiry {
            let expiryParts = expiry.split(separator: "/")
            self.card.expMonth = expiryParts.count > 0 ? String(expiryParts[0]).numbers : ""
            self.card.expYear = expiryParts.count > 1 ? String(expiryParts[1]).numbers : ""
        }
        
    

        let monthNumber = Int(self.card.expMonth)
        let yearNumber = Int(self.card.expYear)

        let actualType = validator.actualType
        self.isValid = actualType != nil && validator.isValid && (!config.validateCVC ||  CreditCardValidator.isValidCvc(cvc: cvc, type: actualType!)) && (!config.validateExpiry || (monthNumber != nil && (1...12).contains(monthNumber!) && yearNumber != nil))
        self.isPotentiallyValid = validator.isPotentiallyValid && (!config.validateExpiry || (monthNumber == nil || (1...12).contains(monthNumber!)))
        self.isEmpty = number.isEmpty && cvc.isEmpty && expiry.isEmpty
        self.validationConfig = config

        if !self.isPotentiallyValid {
            if !validator.isPotentiallyValid {
                self.error = .invalidPan
            } else if config.validateExpiry && monthNumber != nil && !(1...12).contains(monthNumber!) {
                self.error = .invalidMonth
            }
        }
    }

    mutating func updateNumber(_ number: String, config: PaymentCardValidationConfig) {
        self = .init(number: number, cvc: self.card.cvc, expiry: self.expiry, config: config)
    }

    mutating func updateCvc(_ cvc: String, config: PaymentCardValidationConfig) {
        self = .init(number: self.card.number, cvc: cvc, expiry: self.expiry, config: config)
    }

    mutating func updateExpiry(_ expiry: String, config: PaymentCardValidationConfig) {
        self = .init(number: self.card.number, cvc: self.card.cvc, expiry: expiry, config: config)
    }
}

extension PaymentCardError {

    var description: String {
        switch self {
        case .invalidPan:
            return "The credit card number you entered was invalid"
        case .invalidMonth:
            return "The month number you entered was invalid"
        case .encryptionFailed(let message):
            return "Encryption failed: \(message)"
        }
    }
}
