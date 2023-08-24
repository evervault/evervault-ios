import XCTest

@testable import EvervaultCore

final class HttpKeysLoaderTest: XCTestCase {

    func testLoadKeys() async throws {
        let http = Http(config: HttpConfig(
            keysUrl: ConfigUrls().keysUrl, apiUrl: ConfigUrls().apiUrl),
             teamId: ProcessInfo.processInfo.environment["VITE_EV_TEAM_UUID"]!,
             appId: ProcessInfo.processInfo.environment["VITE_EV_APP_UUID"]!,
             context: "default"
        )
        let cageKey = try await http.loadKeys()

        XCTAssertEqual(cageKey, CageKey(publicKey: cageKey.ecdhP256KeyUncompressed, isDebugMode: cageKey.isDebugMode))
    }
}
