import XCTest

import Mockingbird

@testable import Evervault

final class NumberHandlerTest: XCTestCase {

    var cipherMock: DataCipherMock!
    var contextMock: DataHandlerContextMock!
    var handler: NumberHandler!

    override func setUp() {
        cipherMock = mock(DataCipher.self)
        contextMock = mock(DataHandlerContext.self)
        handler = NumberHandler(cipher: cipherMock)
    }

    func testCanEncrypt() {
        XCTAssertTrue(handler.canEncrypt(data: 1))
        XCTAssertTrue(handler.canEncrypt(data: -1))
        XCTAssertTrue(handler.canEncrypt(data: 1.3))
        XCTAssertTrue(handler.canEncrypt(data: CGFloat(1.3)))
        XCTAssertTrue(handler.canEncrypt(data: Float(1.3)))
        XCTAssertTrue(handler.canEncrypt(data: Double(1.3)))
        XCTAssertTrue(handler.canEncrypt(data: UInt(3)))
        XCTAssertTrue(handler.canEncrypt(data: UInt8(3)))
        XCTAssertTrue(handler.canEncrypt(data: Decimal(floatLiteral: 1.3)))
    }

    func testCannotEncrypt() {
        XCTAssertFalse(handler.canEncrypt(data: true))
        XCTAssertFalse(handler.canEncrypt(data: "String value"))
        XCTAssertFalse(handler.canEncrypt(data: [1]))
    }

    func testEncryptInt() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: 1, context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "1", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptNegativeInt() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: -1, context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "-1", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptCGFloat() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: CGFloat(1.3), context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "1.3", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptFloat() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: Float(1.3), context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "1.3", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptDouble() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: Double(1.3), context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "1.3", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptUInt() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: UInt(3), context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "3", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptUInt8() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: UInt8(3), context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "3", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptDecimal() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: Decimal(floatLiteral: 1.3), context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "1.3", dataType: "number")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

}
