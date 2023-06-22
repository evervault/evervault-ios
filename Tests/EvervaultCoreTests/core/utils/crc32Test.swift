import XCTest

@testable import EvervaultCore

class crc32Test: XCTestCase {

    func testCrc32() {
        let base64Image = """
        ZW5jcnlwdGVk
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageData = Data(base64Encoded: base64Image)!
        let crc32Hash = crc32(buffer: imageData)
        XCTAssertEqual(crc32Hash, 1467498611)
    }
}
