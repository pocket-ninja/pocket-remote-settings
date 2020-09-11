import PocketRemoteSettings
import XCTest

class MutableClientTests: XCTestCase {
    struct Settings: Equatable {
        var something = ""
    }
    
    func testClientPropogatesValue() {
        let (pipe, client) = RemoteSettingsClient.mutable(Settings())
        
        pipe.accept(Settings(something: #function))
        
        XCTAssertEqual(pipe.value, client.value())
    }
}
