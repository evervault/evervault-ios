import XCTest

@testable import EvervaultCore

final class CageKeyTest: XCTestCase {

    private let publicKey = "BF1/Mo85D7t/XvC3I+YYpJvP+OsSyxIbSrhtDhg1SClQ2xdoyGpXYrplO/f8AZ+7cGkUnMF3tzSfLC5Io8BuNyw="

    func testPublicKey() throws {
        let key = CageKey(publicKey: publicKey)
        XCTAssertEqual(key.ecdhP256KeyUncompressed, publicKey)
        XCTAssertEqual(key.ecdhP256Key, "Al1/Mo85D7t/XvC3I+YYpJvP+OsSyxIbSrhtDhg1SClQ")
    }

}
