//
//  File.swift
//  
//
//  Created by Lammert Westerhoff on 6/9/23.
//

import Foundation

internal enum CreditCardFormatter {

    static func formatCardNumber(_ cardNumber: String) -> String {
        let formattedCardNumber = cardNumber.numbers

        var formattedString = ""

        var groupLengths: [Int]

        if CreditCardValidator(cardNumber).predictedType == .amex {
            groupLengths = [4, 6, 5]
        } else {
            groupLengths = [4, 4, 4, 4, 3]
        }

        var currentIndex = 0
        for length in groupLengths {
            guard currentIndex < formattedCardNumber.count else {
                break
            }
            let startIndex = formattedCardNumber.index(formattedCardNumber.startIndex, offsetBy: currentIndex)
            let endIndex = formattedCardNumber.index(startIndex, offsetBy: min(length, formattedCardNumber.count - currentIndex))
            let group = String(formattedCardNumber[startIndex..<endIndex])
            formattedString += group + " "
            currentIndex += length
        }

        formattedString = String(formattedString.dropLast()) // Remove trailing space

        return formattedString
    }

    static func formatExpiryDate(_ value: String) -> String {
        var formatted = String(value.prefix(5))
        switch formatted.count {
        case 1,2:
            formatted = formatted.numbers
            guard let month = Int(formatted) else {
                return ""
            }
            if formatted.count == 2 {
                formatted = "\(formatted)/"
            } else if month > 1 {
                formatted = "0\(formatted)/"
            }
        default: ()
        }
        return formatted
    }
}
