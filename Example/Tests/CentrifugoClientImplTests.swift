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
    var parser: ParserMock!
    
    override func setUp() {
        super.setUp()
        parser = ParserMock()

        client = CentrifugoClientImpl()
        client.parser = parser
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: - Public interface
    func testConnectCallsWebSocketOpenAndSetupsHandler() {
        // given
        var methodCalled = false
        let ws = WebSocketMock()
        
        ws.openHandler = { methodCalled = true }
        
        client.ws = ws
        
        // when
        client.connect { _ in }
        
        // then
        XCTAssertTrue(methodCalled)
        XCTAssertNotNil(client.blockingHandler)
        XCTAssertNotNil(client.connectionCompletion)
    }
    
    //MARK - Helpers
    func testConnectionProcessHandlerProcessError() {
        // given
        var receivedError: NSError?
        let expectedError = NSError(domain: "", code: 1, userInfo: nil)
        
        client.connectionCompletion = { error in
            receivedError = error
        }
        
        // when
        client.connectionProcessHandler(nil, error: expectedError)
        
        // then
        XCTAssertEqual(receivedError, expectedError)
    }
    
    func testConnectionProcessHandlerProcessValidMessage() {
        // given
        var handlerCalled = false
        var receivedError: NSError?
        
        client.connectionCompletion = { error in
            handlerCalled = true
            receivedError = error
        }
        
        // when
        client.connectionProcessHandler([CentrifugoServerMessage.testMessage()], error: nil)
        
        // then
        XCTAssertNil(receivedError)
        XCTAssertTrue(handlerCalled)
    }
    
    func testConnectionProcessHandlerProcessErrorMessage() {
        // given
        var handlerCalled = false
        var receivedError: NSError!
        let desc = "Error description"
        let message = CentrifugoServerMessage.errorMessage(desc)
        client.connectionCompletion = { error in
            handlerCalled = true
            receivedError = error
        }
        
        // when
        client.connectionProcessHandler([message], error: nil)
        
        // then
        XCTAssertEqual(receivedError.code, CentrifugoErrorCode.CentrifugoMessageWithError.rawValue)
        XCTAssertEqual(receivedError.domain, CentrifugoErrorDomain)
        XCTAssertEqual(receivedError.localizedDescription, desc)
        XCTAssertTrue(handlerCalled)
    }
    
    
    //MARK: - WebSocketDelegate
    func testClientWebSocketOpenSendsMessage() {
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
    
    func testClientWebSocketMessageDataUsesHandler() {
        // given
        var handlerCalled = false
        let data = NSData()
        
        client.blockingHandler = { _, _ in
            handlerCalled = true
        }
        // when
        client.webSocketMessageData(data)
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    func testClientWebSocketMessageDataCallsParser() {
        // given
        var handlerCalled = false
        
        let parser = ParserMock()
        let data = NSData()
        client.parser = parser
        
        parser.parseHandler = { data in
            handlerCalled = true
            return []
        }
        
        // when
        client.webSocketMessageData(data)
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    func testClientWebSocketMessageDataSentValidMessage() {
        // given
        var validMessagesDidReceive = false
        let messages = [CentrifugoServerMessage.testMessage()]
        
        let parser = ParserMock()
        let data = NSData()
        client.parser = parser
        
        parser.parseHandler = { data in
            return messages
        }
        
        client.blockingHandler = { aMessages, error in
            if let msgs = aMessages {
                validMessagesDidReceive = (msgs == messages)
            }
            return
        }
        
        // when
        client.webSocketMessageData(data)
        
        // then
        XCTAssertTrue(validMessagesDidReceive)
    }
    
    func testClientWebSocketCloseUsesHandler() {
        // given
        var handlerCalled = false
        
        client.blockingHandler = { _, _ in
            handlerCalled = true
        }
        // when
        client.webSocketClose(0, reason: "", wasClean: true)
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    func testClientWebSocketErrorUsesHandler() {
        // given
        var handlerCalled = false
        let error = NSError(domain: "", code: 0, userInfo: nil)
        
        client.blockingHandler = { _, _ in
            handlerCalled = true
        }
        // when
        client.webSocketError(error)
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    //MARK: - Helpers
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
    
    class ParserMock: CentrifugoServerMessageParserImpl {
        var parseHandler: ( (NSData) -> [CentrifugoServerMessage] )?
        override func parse(data: NSData) throws -> [CentrifugoServerMessage] {
            if let handler = parseHandler {
                return handler(data)
            } else {
                return []
            }
        }
    }
}


extension CentrifugoClientMessage {
    static func testMessage() -> CentrifugoClientMessage {
        return CentrifugoClientMessage(uid: NSUUID().UUIDString, method: .Connect, params: [:])
    }
}

extension CentrifugoServerMessage {
    static func testMessage() -> CentrifugoServerMessage {
        return CentrifugoServerMessage(uid: NSUUID().UUIDString, method: .Connect, error: nil, body: [:])
    }
    static func errorMessage(decription: String) -> CentrifugoServerMessage {
        return CentrifugoServerMessage(uid: NSUUID().UUIDString, method: .Connect, error: decription, body: [:])
    }
}

extension CentrifugoCredentials {
    static func testCreds() -> CentrifugoCredentials {
        return CentrifugoCredentials(secret: "testSecret", user: "testUser", timestamp: "1234567898")
    }
}
