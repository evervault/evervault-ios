import XCTest

import Mockingbird

@testable import EvervaultCore

final class BooleanHandlerTest: XCTestCase {

    var cipherMock: DataCipherMock!
    var contextMock: DataHandlerContextMock!
    var handler: BooleanHandler!

    override func setUp() {
        cipherMock = mock(DataCipher.self)
        contextMock = mock(DataHandlerContext.self)
        handler = BooleanHandler(cipher: cipherMock)
    }

    func testCanEncrypt() {
        XCTAssertTrue(handler.canEncrypt(data: true))
        XCTAssertTrue(handler.canEncrypt(data: false))
    }

    func testCannotEncrypt() {
        XCTAssertFalse(handler.canEncrypt(data: "String value"))
        XCTAssertFalse(handler.canEncrypt(data: 1))
        XCTAssertFalse(handler.canEncrypt(data: [true]))
    }

    func testEncryptTrue() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: true, context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "true", dataType: "boolean")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptFalse() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: false, context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "false", dataType: "boolean")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

}
