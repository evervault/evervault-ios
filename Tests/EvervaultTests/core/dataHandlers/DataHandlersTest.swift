import XCTest

import Mockingbird

@testable import Evervault

final class DataHandlersTest: XCTestCase {

    var cipherMock: DataCipherMock!
    var contextMock: DataHandlerContextMock!
    var dataHandlers: DataHandlers!

    override func setUp() {
        cipherMock = mock(DataCipher.self)
        contextMock = mock(DataHandlerContext.self)
        dataHandlers = DataHandlers(cipher: cipherMock)
    }

    func testEncryptComplex() throws {
        given(cipherMock.encryptString(string: any(), dataType: any())).will { string, type in
            "_\(type):\(string)_"
        }

        let result = try dataHandlers.encrypt(data: [
            "a": [1, 2],
            2: [
                "b": true,
                "c": 1.4
            ] as [String : Any],
            true: false
        ] as [AnyHashable : Any])

        XCTAssertTrue(result is [AnyHashable: Any])
        let dictionaryResult = result as! [AnyHashable: Any]
        XCTAssertEqual(dictionaryResult.count, 3)

        XCTAssertEqual(dictionaryResult["a"] as! [String], ["_number:1_", "_number:2_"])

        let dict2 = dictionaryResult[2] as! [String: Any]
        XCTAssertEqual(dict2.count, 2)
        XCTAssertEqual(dict2["b"] as! String, "_boolean:true_")
        XCTAssertEqual(dict2["c"] as! String, "_number:1.4_")

        XCTAssertEqual(dictionaryResult[true] as! String, "_boolean:false_")

        verify(cipherMock.encryptString(string: any(), dataType: any())).wasCalled(5)
    }
}
