import UIKit
import XCTest
@testable import CentrifugeiOS

class CentrifugeClientMessageBuilderImplTests: XCTestCase {
    
    var builder: CentrifugeClientMessageBuilderImpl!
    
    override func setUp() {
        super.setUp()
        
        builder = CentrifugeClientMessageBuilderImpl()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBuildingConnectMessageWithoutInfo() {
        // given
        let cred = CentrifugeCredentials(secret: "secret", user: "user", timestamp: "timestamp")
        
        // when
        let message = builder.buildConnectMessage(cred)
        
        // then
        XCTAssertEqual(message.method, CentrifugeMethod.Connect)
        XCTAssertNotNil(message.params["token"])
        XCTAssertNotNil(message.params["user"])
        XCTAssertNotNil(message.params["timestamp"])
        XCTAssertNil(message.params["info"])
    }
    
    func testBuildingConnectMessageWithInfo() {
        // given
        let cred = CentrifugeCredentials(secret: "secret", user: "user", timestamp: "timestamp", info: "info")
        
        // when
        let message = builder.buildConnectMessage(cred)
        
        // then
        XCTAssertEqual(message.method, CentrifugeMethod.Connect)
        XCTAssertNotNil(message.params["token"])
        XCTAssertNotNil(message.params["user"])
        XCTAssertNotNil(message.params["timestamp"])
        XCTAssertNotNil(message.params["info"])
    }
}
