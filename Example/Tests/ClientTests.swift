import PocketRemoteSettings
import XCTest

class ClientTests: XCTestCase {
    struct Settings {
        var something = ""
    }

    func testClientBuildsWithDynamicMemberLookup() {
        let client = RemoteSettingsClient.constant(Settings(something: ""))
        XCTAssertEqual(client.something, "")
    }
}
