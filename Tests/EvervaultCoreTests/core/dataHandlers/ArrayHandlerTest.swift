import XCTest

import Mockingbird

@testable import EvervaultCore

final class ArrayHandlerTest: XCTestCase {

    var contextMock: DataHandlerContextMock!
    var handler: ArrayHandler!

    override func setUp() {
        contextMock = mock(DataHandlerContext.self)
        handler = ArrayHandler()
    }

    func testCanEncrypt() {
        XCTAssertTrue(handler.canEncrypt(data: [String]()))
        XCTAssertTrue(handler.canEncrypt(data: ["a", "b"]))
        XCTAssertTrue(handler.canEncrypt(data: [1, 2]))
        XCTAssertTrue(handler.canEncrypt(data: ["a", 2] as [Any]))
        XCTAssertTrue(handler.canEncrypt(data: [["a", "b"], 2] as [Any]))
    }

    func testCannotEncrypt() {
        XCTAssertFalse(handler.canEncrypt(data: "String value"))
        XCTAssertFalse(handler.canEncrypt(data: 1))
        XCTAssertFalse(handler.canEncrypt(data: true))
        XCTAssertFalse(handler.canEncrypt(data: false))
    }

    func testEncryptEmptyStringArray() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        XCTAssertEqual(try handler.encrypt(data: [String](), context: contextMock) as? [String], [String]())
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptStringArray() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        XCTAssertEqual(try handler.encrypt(data: ["a", "b"], context: contextMock) as? [String], ["a", "b"])
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }

    func testEncryptNumbersArray() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        XCTAssertEqual(try handler.encrypt(data: [1, 2], context: contextMock) as? [Int], [1, 2])
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }

    func testEncryptMixedArray() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        let result = try handler.encrypt(data: ["a", 2] as [Any], context: contextMock) as? [Any]
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 2)
        XCTAssertEqual(result![0] as? String, "a")
        XCTAssertEqual(result![1] as? Int, 2)
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }

    func testEncryptMixedMultidimensionalArray() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        let result = try handler.encrypt(data: [["a", "b"], 2] as [Any], context: contextMock) as? [Any]
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 2)
        XCTAssertEqual(result![0] as? [String], ["a", "b"])
        XCTAssertEqual(result![1] as? Int, 2)
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }
}
