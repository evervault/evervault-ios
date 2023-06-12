import XCTest

@testable import EvervaultCore

final class CageKeyTest: XCTestCase {

    private let publicKey = "BDeIKmwjqB35+tnMzQFEvXIvM2kyK6DX75NBEhSZxCR5CQZYnh1fwWsXMEqqKihmEGfMX0+EDHtmZNP/TK7mqMc="

    override func setUpWithError() throws {
        Evervault.shared.configure(
            teamId: ProcessInfo.processInfo.environment["VITE_EV_TEAM_UUID"]!,
            appId: ProcessInfo.processInfo.environment["VITE_EV_APP_UUID"]!,
            customConfig: CustomConfig(isDebugMode: true, publicKey: publicKey)
        )
    }

    func testPublicKey() throws {
        let key = CageKey(publicKey: publicKey)
        XCTAssertEqual(key.ecdhP256KeyUncompressed, publicKey)
        XCTAssertEqual(key.ecdhP256Key, "AzeIKmwjqB35+tnMzQFEvXIvM2kyK6DX75NBEhSZxCR5")
    }

}
