import XCTest
@testable import EvervaultInputs

final class CreditCardFormatterTests: XCTestCase {
    func testCreditCardFormatting() {
        let values: [(String, String)] = [
            ("3782 8224 6310 005", "3782 822463 10005"),
            ("378282246310005", "3782 822463 10005"),
            ("378282246", "3782 82246"),
            ("378282", "3782 82"),
            ("3782", "3782"),
            ("4111 1111 1111 1111", "4111 1111 1111 1111"),
            ("4111111111111111", "4111 1111 1111 1111"),
            ("4111 11", "4111 11"),
            ("411111", "4111 11"),
            ("4111", "4111"),
            ("375987654321001", "3759 876543 21001"),
            ("37598765432100111", "3759 876543 21001"),
            ("1234567890123456", "1234 5678 9012 3456"),
            ("1234567890123456123", "1234 5678 9012 3456 123"),
            ("", ""),
            ("1", "1"),
            ("11", "11"),
            ("111", "111"),
            ("1111", "1111"),
            ("11111", "1111 1"),
            ("111111111111111111111111111111111", "1111 1111 1111 1111 111"),
            ("11aa2233", "1122 33"),
        ]
        values.forEach { (item) in
            XCTAssertEqual(CreditCardFormatter.formatCardNumber(item.0), item.1)
        }
    }
}
