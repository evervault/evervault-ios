import XCTest

import Mockingbird

@testable import EvervaultCore

final class StringHandlerTest: XCTestCase {

    var encryptionServiceMock: EncryptionServiceMock!
    var contextMock: DataHandlerContextMock!
    var handler: StringHandler!

    override func setUp() {
        encryptionServiceMock = mock(EncryptionService.self)
        contextMock = mock(DataHandlerContext.self)
        handler = StringHandler(encryptionService: encryptionServiceMock)
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
        given(encryptionServiceMock.encryptString(string: any(), dataType: any())).willReturn("encrypted")
        XCTAssertEqual(try handler.encrypt(data: "String value", context: contextMock) as? String, "encrypted")
        verify(encryptionServiceMock.encryptString(string: "String value", dataType: .string)).wasCalled()
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

}
