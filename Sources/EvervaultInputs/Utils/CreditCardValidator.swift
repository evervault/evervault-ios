// original source: https://github.com/vitkuzmenko/CreditCardValidator/blob/master/Sources/CreditCardValidator/CreditCardValidator.swift

/*
 The MIT License (MIT)
 Copyright (c) 2014 Hearst

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

internal struct CreditCardValidator {

    /// Available credit card types
    private static let types: [CreditCardType] = [
        .amex,
        .visa,
        .masterCard,
        .maestro,
        .dinersClub,
        .jcb,
        .discover,
        .unionPay,
    ]

    let string: String

    private static let maxCvcLength = 3
    private static let maxCvcLengthAmex = 4

    /// Create validation value
    /// - Parameter string: credit card number
    public init(_ string: String) {
        self.string = string.numbers
    }

    /// Get predicted card type
    /// Card number validation is not perfroms here
    public var predictedType: CreditCardType? {
        CreditCardValidator.types.first { type in
            NSPredicate(format: "SELF MATCHES %@", "^\(type.prefixRegex).*$")
                .evaluate(
                    with: string
                )
        }
    }

    /// Get cactual ard type
    /// Card number validation is not perfroms here
    public var actualType: CreditCardType? {
        CreditCardValidator.types.first { type in
            NSPredicate(format: "SELF MATCHES %@", type.regex)
                .evaluate(
                    with: string
                )
        }
    }

    /// Calculation structure
    private struct Calculation {
        let odd, even: Int
        func result() -> Bool {
            (odd + even) % 10 == 0
        }
    }

    /// Validate credit card number
    public var isValid: Bool {
        guard let type = actualType else { return false }
        let isValidLength = type.validNumberLength.contains(string.count)
        return isValidLength && CreditCardValidator.isValid(for: string)
    }

    public var isPotentiallyValid: Bool {
        guard !isValid else {
            return true
        }

        guard let type = predictedType else {
            return !NSPredicate(format: "SELF MATCHES %@", CreditCardType.invalidRegex).evaluate(with: string) && string.count <= 4
        }

        return string.count < type.validNumberLength.last!
    }

    /// Validate card number string for type
    /// - Parameters:
    ///   - string: card number string
    ///   - type: credit card type
    /// - Returns: bool value
    public func isValid(for type: CreditCardType) -> Bool {
        isValid && self.actualType == type
    }

    public static func maxCvcLength(for type: CreditCardType?) -> Int {
        guard let type else {
            return CreditCardType.allCases.map(maxCvcLength(for:)).max()!
        }
        switch type {
        case .amex: return maxCvcLengthAmex
        default: return maxCvcLength
        }
    }

    public static func isValidCvc(cvc: String, type: CreditCardType) -> Bool {
        return cvc
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .count == maxCvcLength(for: type)
    }

    /// Validate string for credit card type
    /// - Parameters:
    ///   - string: card number string
    /// - Returns: bool value
    private static func isValid(for string: String) -> Bool {
        string
            .reversed()
            .compactMap({ Int(String($0)) })
            .enumerated()
            .reduce(Calculation(odd: 0, even: 0), { value, iterator in
                return .init(
                    odd: odd(value: value, iterator: iterator),
                    even: even(value: value, iterator: iterator)
                )
            })
            .result()
    }
    
    private static func odd(value: Calculation, iterator: EnumeratedSequence<[Int]>.Element) -> Int {
        iterator.offset % 2 != 0 ? value.odd + (iterator.element / 5 + (2 * iterator.element) % 10) : value.odd
    }

    private static func even(value: Calculation, iterator: EnumeratedSequence<[Int]>.Element) -> Int {
        iterator.offset % 2 == 0 ? value.even + iterator.element : value.even
    }

}

internal extension CreditCardType {

    static let invalidRegex = "^(?:1|7|9).*"

    // used for early type detection
    var prefixRegex: String {
        switch self {
        case .amex: return "3[47]"
        case .visa: return "4"
        case .masterCard: return "(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)"
        case .maestro: return "(?:5[0678]\\d\\d|6304|6390|67\\d\\d)"
        case .dinersClub: return "3(?:0[0-5]|[68][0-9])"
        case .jcb: return "(?:2131|1800|35[0-9]{3})"
        case .discover: return "6(?:011|5[0-9]{2})"
        case .unionPay: return "62[0-5]\\d"
        }
    }

    var remainingRegex: String {
        switch self {
        case .amex: return "[0-9]{5,}"
        case .visa: return "[0-9]{6,}"
        case .masterCard: return "[0-9]{12}"
        case .maestro: return "\\d{8,15}"
        case .dinersClub: return "[0-9]{4,}"
        case .jcb: return "[0-9]{3,}"
        case .discover: return "[0-9]{3,}"
        case .unionPay: return "{13,16}"
        }
    }

    var regex: String {
        return "^\(prefixRegex)\(remainingRegex)$"
    }

    /// Possible C/C number lengths for each C/C type
    /// reference: https://en.wikipedia.org/wiki/Payment_card_number
    var validNumberLength: IndexSet {
        switch self {
        case .visa:
            return IndexSet([13,16])
        case .amex:
            return IndexSet(integer: 15)
        case .maestro:
            return IndexSet(integersIn: 12...19)
        case .dinersClub:
            return IndexSet(integersIn: 14...19)
        case .jcb, .discover, .unionPay:
            return IndexSet(integersIn: 16...19)
        default:
            return IndexSet(integer: 16)
        }
    }
}

internal extension String {

    var numbers: String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = components(separatedBy: set)
        return numbers.joined(separator: "")
    }

}
