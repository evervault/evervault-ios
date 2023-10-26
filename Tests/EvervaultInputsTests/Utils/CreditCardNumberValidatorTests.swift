// original source: https://github.com/vitkuzmenko/CreditCardValidator/blob/master/Tests/CreditCardValidatorTests/CreditCardValidatorTests.swift

import XCTest
@testable import EvervaultInputs

final class CreditCardNumberValidatorTests: XCTestCase {

    /// Card numbers provided from
    /// https://www.paypalobjects.com/en_GB/vhelp/paypalmanager_help/credit_card_numbers.htm
    /// https://docs.adyen.com/development-resources/test-cards/test-card-numbers
    //// https://www.kobzarev.com/other/testoviye-nomera-kreditnyh-kart/
    func testValidData() {
        print("Start test")
        let values: [(CreditCardType, String)] = [
            (.amex, "3782 8224 6310 005"),
            (.amex, "3714 4963 5398 431"),
            (.amex, "3787 3449 3671 000"),
            (.visa, "4111 1111 1111 1111"),
            (.visa, "4012 8888 8888 1881"),
            (.visa, "4222 2222 2222 2"),
            (.visa, "4556 7375 8689 9855"),
            (.masterCard, "5500 0000 0000 0004"),
            (.masterCard, "5555 5555 5555 4444"),
            (.masterCard, "5105 1051 0510 5100"),
            (.masterCard, "2222 4107 4036 0010"),
            (.maestro, "6771 7980 2100 0008"),
            (.dinersClub, "30569309025904"),
            (.jcb, "3569 9900 1009 5841"),
            (.discover, "6011 0000 0000 0004"),
            (.unionPay, "6250 9470 0000 0014"),
            (.elo, "5066 9911 0917 9242"),
        ]
        values.forEach { (item) in
            XCTAssertTrue(CreditCardNumberValidator(item.1).isValid, "\(item.1) is not valid")
            XCTAssertEqual(item.0, CreditCardNumberValidator(item.1).actualType)
            XCTAssertEqual(item.0, CreditCardNumberValidator(item.1).predictedType)
            XCTAssertTrue(CreditCardNumberValidator(item.1).isValid(for: item.0))
        }
    }

    func testInvalidData() {
        let values: [(CreditCardType, String)] = [
            (.amex, "3782 8224 6310 006"),
            (.amex, "3714 4963 5398 432"),
            (.amex, "3787 3449 3671 001"),
            (.amex, "3715 6536 866"),
            (.visa, "4111 1111 1111 1112"),
            (.visa, "4012 8888 8888 1882"),
            (.visa, "4222 2222 2222 3"),
            (.visa, "4222 2222 2222"),
            (.masterCard, "5500 0000 0000 0005"),
            (.masterCard, "5555 5555 5555 4445"),
            (.masterCard, "5105 1051 0510 5101"),
            (.masterCard, "2222 4107 4036 0011"),
            (.masterCard, "2222 4107 4036 0011"),
            (.maestro, "6771 7980 2100 0009"),
            (.dinersClub, "30569309025905"),
            (.dinersClub, "30569309021"),
            (.jcb, "3569 9900 1009 5842"),
            (.jcb, "3569 9900 1009 3"),
            (.discover, "6011 0000 0000 0005"),
            (.discover, "6011 0000 001"),
            (.unionPay, "6250 9470 0000 0015"),
        ]
        values.forEach { (item) in
            XCTAssertFalse(CreditCardNumberValidator(item.1).isValid)
            if let type = CreditCardNumberValidator(item.1).actualType {
                XCTAssertEqual(item.0, type)
            }
            XCTAssertEqual(item.0, CreditCardNumberValidator(item.1).predictedType)
            XCTAssertFalse(CreditCardNumberValidator(item.1).isValid(for: item.0))
        }
    }

    func testPartialData() {

        let values: [(CreditCardType, String)] = [
            (.amex, "3782"),
            (.amex, "3714"),
            (.amex, "3787"),
            (.visa, "411122"),
            (.visa, "401222"),
            (.visa, "422222"),
            (.masterCard, "5500"),
            (.masterCard, "5555"),
            (.masterCard, "5105"),
            (.masterCard, "2222"),
            (.maestro, "6771"),
            (.dinersClub, "3056"),
            (.jcb, "3569 9"),
            (.discover, "6011"),
            (.unionPay, "6250"),
        ]
        values.forEach { (item) in
            XCTAssertFalse(CreditCardNumberValidator(item.1).isValid)
            XCTAssertNil(CreditCardNumberValidator(item.1).actualType)
            XCTAssertEqual(item.0, CreditCardNumberValidator(item.1).predictedType)
            XCTAssertFalse(CreditCardNumberValidator(item.1).isValid(for: item.0))
        }
    }

    static var allTests = [
        ("testValidData", testValidData),
        ("testInvalidData", testValidData),
    ]
}
