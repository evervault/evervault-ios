import XCTest

@testable import EvervaultCore

class ecPointCompressTest: XCTestCase {
    func testEcPointCompression() {
        let uncompressed = "BF1/Mo85D7t/XvC3I+YYpJvP+OsSyxIbSrhtDhg1SClQ2xdoyGpXYrplO/f8AZ+7cGkUnMF3tzSfLC5Io8BuNyw="
        let keyData = Data(base64Encoded: uncompressed.data(using: .utf8)!)!
        let compressed = ecPointCompress(ecdhRawPublicKey: keyData)
        let base64Compressed = compressed.base64EncodedString()
        XCTAssertEqual(base64Compressed, "Al1/Mo85D7t/XvC3I+YYpJvP+OsSyxIbSrhtDhg1SClQ")
    }
}
