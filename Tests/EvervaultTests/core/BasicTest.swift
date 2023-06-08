import XCTest

@testable import Evervault

final class BasicTest: XCTestCase {

    private let publicKey = "BDeIKmwjqB35+tnMzQFEvXIvM2kyK6DX75NBEhSZxCR5CQZYnh1fwWsXMEqqKihmEGfMX0+EDHtmZNP/TK7mqMc="

    override func setUpWithError() throws {
        Evervault.shared.configure(
            teamId: ProcessInfo.processInfo.environment["VITE_EV_TEAM_UUID"]!,
            appId: ProcessInfo.processInfo.environment["VITE_EV_APP_UUID"]!
//            customConfig: CustomConfig(
//                isDebugMode: true
//            )
        )
    }

    func testPublicKey() async throws {
        let encryptedString = try await Evervault.shared.encrypt("Big Secret")
        XCTAssertEqual(encryptedString, "ev:")
    }

}
