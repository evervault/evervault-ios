// original source: https://github.com/vitkuzmenko/CreditCardValidator/blob/master/Sources/CreditCardValidator/CreditCardValidator.swift

/*
 The MIT License (MIT)
 Copyright (c) 2014 Hearst

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public enum CreditCardType: String, CaseIterable {
    case amex
    case dinersClub
    case discover
    case jcb
    case elo
    case hiper
    case hipercard
    case maestro
    case masterCard
    case mir
    case unionPay
    case visa

    public var brand: String {
        switch self {
        case .amex:
            return "American Express"
        case .dinersClub:
            return "Diners Club"
        case .discover:
            return "Discover"
        case .jcb:
            return "JCB"
        case .elo:
            return "Elo"
        case .hiper:
            return "Hiper"
        case .hipercard:
            return "Hipercard"
        case .maestro:
            return "Maestro"
        case .masterCard:
            return "Mastercard"
        case .mir:
            return "Mir"
        case .unionPay:
            return "UnionPay"
        case .visa:
            return "Visa"
        }
    }
}
