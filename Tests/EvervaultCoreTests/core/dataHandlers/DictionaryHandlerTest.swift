import XCTest

import Mockingbird

@testable import EvervaultCore

final class DictionaryHandlerTest: XCTestCase {

    var contextMock: DataHandlerContextMock!
    var handler: DictionaryHandler!

    override func setUp() {
        contextMock = mock(DataHandlerContext.self)
        handler = DictionaryHandler()
    }

    func testCanEncrypt() {
        XCTAssertTrue(handler.canEncrypt(data: [String: String]()))
        XCTAssertTrue(handler.canEncrypt(data: ["a": "A", "b": "B"]))
        XCTAssertTrue(handler.canEncrypt(data: [1: 10, 2: 20]))
        XCTAssertTrue(handler.canEncrypt(data: ["a": 1, 2: "b"] as [AnyHashable: Any]))
        XCTAssertTrue(handler.canEncrypt(data: ["z": ["a": 1, "b": "B"] as [String : Any], 2: true] as [AnyHashable: Any]))
    }

    func testCannotEncrypt() {
        XCTAssertFalse(handler.canEncrypt(data: "String value"))
        XCTAssertFalse(handler.canEncrypt(data: 1))
        XCTAssertFalse(handler.canEncrypt(data: true))
        XCTAssertFalse(handler.canEncrypt(data: false))
        XCTAssertFalse(handler.canEncrypt(data: [String]()))
    }

    func testEncryptEmptyStringDictionary() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        XCTAssertEqual(try handler.encrypt(data: [String: String](), context: contextMock) as? [String: String], [String: String]())
        verify(contextMock.encrypt(data: any())).wasNeverCalled()
    }

    func testEncryptStringDictionary() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        XCTAssertEqual(try handler.encrypt(data: ["a": "A", "b": "B"], context: contextMock) as? [String: String], ["a": "A", "b": "B"])
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }

    func testEncryptNumbersDictionary() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        XCTAssertEqual(try handler.encrypt(data: [1: 10, 2: 20], context: contextMock) as? [Int: Int], [1: 10, 2: 20])
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }

    func testEncryptMixedDictionary() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        let result = try handler.encrypt(data: ["a": 1, 2: "b"] as [AnyHashable: Any], context: contextMock) as? [AnyHashable: Any]
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 2)
        XCTAssertEqual(result!["a"] as? Int, 1)
        XCTAssertEqual(result![2] as? String, "b")
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }

    func testEncryptMixedMultidimensionalDictionary() throws {
        given(contextMock.encrypt(data: any())).will { $0 }
        let result = try handler.encrypt(data: ["z": ["a": 1, "b": "B"] as [String : Any], 2: true] as [AnyHashable: Any], context: contextMock) as? [AnyHashable: Any]
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 2)
        let inner = result!["z"] as? [String : Any]
        XCTAssertNotNil(inner)
        XCTAssertEqual(inner!["a"] as? Int, 1)
        XCTAssertEqual(inner!["b"] as? String, "B")
        XCTAssertEqual(result![2] as? Bool, true)
        verify(contextMock.encrypt(data: any())).wasCalled(2)
    }
}
