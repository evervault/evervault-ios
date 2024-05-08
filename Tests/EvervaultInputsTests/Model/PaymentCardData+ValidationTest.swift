import XCTest

@testable import EvervaultInputs

final class PaymentCardValidationTests: XCTestCase {
    let validCardNumber = "4242424242424242"
    let validCVC = "123"
    let validExpiry = "01/35"
    
    let invalidCardNumber = "233423123"
    let invalidCVC = "12"
    let invalidExpiry = "01/11"
    
    func testCreditCardIsValid() {
        let validCardNumber = PaymentCardData(number: validCardNumber, cvc: validCVC, expiry: validExpiry)
        
        XCTAssert(validCardNumber.isValid)
    }
    
    func testEnablingAllFieldIsValid() {
        let validCardNumber = PaymentCardData(number: validCardNumber, cvc: validCVC, expiry: validExpiry, fields: EnabledFields(isCardNumberEnabled: true, isExpiryEnabled: true, isCVCEnabled: true))
        
        XCTAssert(validCardNumber.isValid)
    }
    
    func testEnableCardNumberOnlyIsValid() {
        let validCardNumber = PaymentCardData(number: validCardNumber, cvc: validCVC, expiry: validExpiry, fields: EnabledFields(isCardNumberEnabled: true, isExpiryEnabled: false, isCVCEnabled: false))
        
        XCTAssert(validCardNumber.isValid)
    }
    
    func testEnableCardNumberOnlyWithInvalidCardIsNotValid() {
        let validCardNumber = PaymentCardData(number: invalidCardNumber, cvc: validCVC, expiry: validExpiry, fields: EnabledFields(isCardNumberEnabled: true, isExpiryEnabled: false, isCVCEnabled: false))
        
        XCTAssert(!validCardNumber.isValid)
    }
    
    func testEnableCardNumberAndExpiryWithInvalidExpiryIsNotValid() {
        let validCardNumber = PaymentCardData(number: validCardNumber, cvc: validCVC, expiry: invalidExpiry, fields: EnabledFields(isCardNumberEnabled: true, isExpiryEnabled: true, isCVCEnabled: false))
        
        XCTAssert(!validCardNumber.isValid)
    }
    
    func testEnableCardNumberAndCVCWithInvalidCVCIsNotValid() {
        let validCardNumber = PaymentCardData(number: validCardNumber, cvc: invalidCVC, expiry: invalidExpiry, fields: EnabledFields(isCardNumberEnabled: true, isExpiryEnabled: false, isCVCEnabled: true))
        
        XCTAssert(!validCardNumber.isValid)
    }
        
    func testEnableCVCAndExpiryIsNotValidWithoutCardNumber() {
        let validCardNumber = PaymentCardData(number: validCardNumber, cvc: validCVC, expiry: validExpiry, fields: EnabledFields(isCardNumberEnabled: false, isExpiryEnabled: true, isCVCEnabled: true))
        
        XCTAssert(!validCardNumber.isValid)
    }
}
