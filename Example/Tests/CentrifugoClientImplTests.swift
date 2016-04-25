//
//  CentrifugoClientImplTests.swift
//  CentrifugoiOS
//
//  Created by Herman Saprykin on 25/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import SwiftWebSocket
@testable import CentrifugoiOS

class CentrifugoClientImplTests: XCTestCase {
    
    var client: CentrifugoClientImpl!
    
    override func setUp() {
        super.setUp()
        
        client = CentrifugoClientImpl()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testConnectCallsWebSocketOpen() {
        // given
        var methodCalled = false
        let ws = WebSocketMock()
        
        ws.openHandler = { methodCalled = true }
        
        client.ws = ws
        
        // when
        client.connect { _ in }
        
        // then
        XCTAssertTrue(methodCalled)
    }
    
    func testDidConnectSendsMessage() {
        // given
        var validMessageDidSend = false
        client.creds = CentrifugoCredentials.testCreds()

        let builder = BuilderMock()
        client.builder = builder
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildConnectHandler = { _ in return message }
    
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.webSocketOpen()
        
        // then
        XCTAssertTrue(validMessageDidSend)
    }
    
    
    class WebSocketMock: CentrifugoWebSocket {
        var openHandler: (Void -> Void)?
        var sendHandler: (CentrifugoClientMessage -> Void)?
        
        override func open() {
            self.openHandler?()
        }
        
        override func send(message: CentrifugoClientMessage) throws {
            self.sendHandler?(message)
        }
    }
    
    class BuilderMock: CentrifugoClientMessageBuilderImpl {
        var buildConnectHandler: ( CentrifugoCredentials -> CentrifugoClientMessage )!
        override func buildConnectMessage(credentials: CentrifugoCredentials) -> CentrifugoClientMessage {
            return self.buildConnectHandler(credentials)
        }
    }
}

extension CentrifugoClientMessage {
    static func testMessage() -> CentrifugoClientMessage {
        return CentrifugoClientMessage(uid: NSUUID().UUIDString, method: .Connect, params: [:])
    }
}

extension CentrifugoCredentials {
    static func testCreds() -> CentrifugoCredentials {
        return CentrifugoCredentials(secret: "testSecret", user: "testUser", timestamp: "1234567898")
    }
}
