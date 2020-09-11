import PocketRemoteSettings
import XCTest

class FirebaseClientTests: XCTestCase {
    struct Settings: Decodable {
        var something = ""
    }

    func testBuildsFirebaseClient() {
        _ = RemoteSettingsClient.firebase(initial: Settings())
    }
}
