import XCTest

import Mockingbird

@testable import Evervault

final class StringHandlerTest: XCTestCase {

    var cipherMock: DataCipherMock!
    var contextMock: DataHandlerContextMock!
    var handler: StringHandler!

    override func setUp() {
        cipherMock = mock(DataCipher.self)
        contextMock = mock(DataHandlerContext.self)
        handler = StringHandler(cipher: cipherMock)
    }

    func testCanEncrypt() {
        XCTAssertTrue(handler.canEncrypt(data: "String value"))
        XCTAssertTrue(handler.canEncrypt(data: ""))
    }

    func testCannotEncrypt() {
        XCTAssertFalse(handler.canEncrypt(data: true))
        XCTAssertFalse(handler.canEncrypt(data: 1))
        XCTAssertFalse(handler.canEncrypt(data: ["a"]))
    }

    func testEncrypt() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: "String value", context: contextMock) as? String, "encrypted")
        verify(cipherMock.encryptString(string: "String value", dataType: "string")).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

}
