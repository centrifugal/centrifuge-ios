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
    
    func testPingProcessValid() {
        // given
        var validMessageDidSend = false

        let ws = WebSocketMock()
        let builder = BuilderMock()
        
        client.builder = builder
        client.ws = ws
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildPingHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.ping { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
    }
    
    func testSubscribeProcessValid() {
        // given
        var validMessageDidSend = false
        
        let channel = "channelName"
        let delegate = ChannelDelegateMock()
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildSubscribeHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.subscribe(channel, delegate: delegate) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
        XCTAssertNotNil(client.subscription[channel])
    }
    
    func testSubscribeWithRecoveryProcessValid() {
        // given
        var validMessageDidSend = false
        let uid = NSUUID().UUIDString
        
        let channel = "channelName"
        let delegate = ChannelDelegateMock()
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildSubscribeWithRecoveryHandler = { _, _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.subscribe(channel, delegate: delegate, lastMessageUID: uid) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
        XCTAssertNotNil(client.subscription[channel])
    }
    
    func testUnubscribeProcessValid() {
        // given
        var validMessageDidSend = false
        
        let channel = "channelName"
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildUnsubscribeHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        client.subscription[channel] = ChannelDelegateMock()
        
        // when
        client.unsubscribe(channel) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
    }
    
    func testHistoryProcessValid() {
        // given
        var validMessageDidSend = false
        
        let channel = "channelName"
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildHistoryHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.history(channel) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
    }
    
    func testPresenceProcessValid() {
        // given
        var validMessageDidSend = false
        
        let channel = "channelName"
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildPresenceHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.presence(channel) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
    }
    
    func testPublishProcessValid() {
        // given
        var validMessageDidSend = false
        
        let channel = "channelName"
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugoClientMessage.testMessage()
        
        builder.buildPublishHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.publish(channel, data: [:]) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
    }
    
    //MARK: - Helpers
    func testDefaultProcessHandlerProcessError() {
        // given
        let expectedError = NSError(domain: "", code: 1, userInfo: nil)
        let delegate = ClientDelegateMock()
        
        client.delegate = delegate
        
        // when
        client.defaultProcessHandler(nil, error: expectedError)
        
        // then
        XCTAssertEqual(delegate.receivedError, expectedError)
    }
    
    func testDefaultProcessHandlerProcessMessageWithError() {
        // given
        let channel = "myChannel"
        
        let message = CentrifugoServerMessage(uid: NSUUID().UUIDString, method: .Publish, error: "decription", body: ["channel":channel])
        
        var receivedMessage: CentrifugoServerMessage?
        var receivedError: NSError?
        
        client.messageCallbacks[message.uid!] = { message, error in
            receivedMessage = message
            receivedError = error
        }
        
        // when
        client.defaultProcessHandler([message], error: nil)
        
        // then
        XCTAssertNil(receivedMessage)
        XCTAssertNotNil(receivedError)
        XCTAssertNil(client.messageCallbacks[message.uid!])
    }
    
    func testDefaultProcessHandlerCallsMessageCallbacksAndRemoveCallback() {
        // given
        let expectedMessage = CentrifugoServerMessage.testMessage()
        var receivedMessage: CentrifugoServerMessage!
        
        client.messageCallbacks[expectedMessage.uid!] = { message, _ in
            receivedMessage = message
        }
        
        // when
        client.defaultProcessHandler([expectedMessage], error: nil)
        
        // then
        XCTAssertEqual(expectedMessage, receivedMessage)
        XCTAssertNil(client.messageCallbacks[expectedMessage.uid!])
    }
    
    func testDefaultProcessHandlerCallsMessageChannelDelegate() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        
        let message = CentrifugoServerMessage(uid: nil, method: .Message, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.messageHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        
        // when
        client.defaultProcessHandler([message], error: nil)
        
        // then
        XCTAssertEqual(expectedChannel, receivedChannel)
    }
    
    func testDefaultProcessHandlerCallsJoinChannelDelegate() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        
        let message = CentrifugoServerMessage(uid: nil, method: .Join, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.joinHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        
        // when
        client.defaultProcessHandler([message], error: nil)
        
        // then
        XCTAssertEqual(expectedChannel, receivedChannel)
    }
    
    func testDefaultProcessHandlerCallsLeaveChannelDelegate() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        
        let message = CentrifugoServerMessage(uid: nil, method: .Leave, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.leaveHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        
        // when
        client.defaultProcessHandler([message], error: nil)
        
        // then
        XCTAssertEqual(expectedChannel, receivedChannel)
    }
    
    func testDefaultProcessHandlerCallsUnsubscribeChannelDelegateAndHandler() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        var handlerCalled = false
        let uid = NSUUID().UUIDString
        
        let message = CentrifugoServerMessage(uid: uid, method: .Unsubscribe, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.unsubscribeHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        client.messageCallbacks[uid] = { _, _ in
            handlerCalled = true
        }
        
        // when
        client.defaultProcessHandler([message], error: nil)
        
        // then
        XCTAssert(handlerCalled)
        XCTAssertEqual(expectedChannel, receivedChannel)
        XCTAssertNil(client.subscription[expectedChannel])
    }
    
    func testConnectionProcessHandlerResetsStateIfError() {
        // given
        let error = NSError(domain: "", code: 1, userInfo: nil)

        client.connectionCompletion = { _ in
        }
        client.blockingHandler = client.connectionProcessHandler
        
        // when
        client.connectionProcessHandler(nil, error: error)
        
        // then
        XCTAssertNil(client.blockingHandler)
        XCTAssertNil(client.connectionCompletion)
    }
    
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
        XCTAssertNotNil(client.blockingHandler)
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
        if let wrapper = receivedError.userInfo[CentrifugoErrorMessageKey] as? CentrifugoWrapper<CentrifugoServerMessage> {
            XCTAssertEqual(message, wrapper.value )
        }else {
            XCTFail()
        }
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
        
        client.blockingHandler = { _, _ in
            handlerCalled = true
        }
        // when
        client.webSocketMessageText("")
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    func testClientWebSocketMessageDataCallsParser() {
        // given
        var handlerCalled = false
        
        let parser = ParserMock()
        let text = "[qw1234]"
        client.parser = parser
        
        parser.parseHandler = { data in
            handlerCalled = true
            return []
        }
        
        // when
        client.webSocketMessageText(text)
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    func testClientWebSocketMessageDataSentValidMessage() {
        // given
        var validMessagesDidReceive = false
        let messages = [CentrifugoServerMessage.testMessage()]
        
        let parser = ParserMock()
        let text = "asdfgh35e4trf"
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
        client.webSocketMessageText(text)
        
        // then
        XCTAssertTrue(validMessagesDidReceive)
    }
    
    func testClientWebSocketCloseUsesHandler() {
        // given
        var handlerCalled = false
        let code = 111
        let reason = "Hello, world"
        
        var receivedCode = -1
        var receivedReason = ""
        
        client.blockingHandler = { _, error in
            if let err = error {
                receivedCode = err.code
                receivedReason = err.localizedDescription
            }
            
            handlerCalled = true
        }
        
        // when
        client.webSocketClose(code, reason: reason, wasClean: true)
        
        // then
        XCTAssertTrue(handlerCalled)
        XCTAssertEqual(receivedReason, reason)
        XCTAssertEqual(receivedCode, code)
    }
    
    func testClientWebSocketErrorUsesHandler() {
        // given
        var handlerCalled = false
        var receivedError: NSError?
        let error = NSError(domain: "", code: 0, userInfo: nil)
        
        client.blockingHandler = { _, error in
            handlerCalled = true
            receivedError = error
        }
        // when
        client.webSocketError(error)
        
        // then
        XCTAssertTrue(handlerCalled)
        XCTAssertEqual(receivedError, error)
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
            return buildConnectHandler(credentials)
        }
        
        var buildPingHandler: ( Void -> CentrifugoClientMessage )!
        override func buildPingMessage() -> CentrifugoClientMessage {
            return buildPingHandler()
        }
        
        var buildSubscribeHandler: ( String -> CentrifugoClientMessage )!
        override func buildSubscribeMessageTo(channel: String) -> CentrifugoClientMessage {
            return buildSubscribeHandler(channel)
        }
        
        var buildSubscribeWithRecoveryHandler: ( (String, String) -> CentrifugoClientMessage )!
        override func buildSubscribeMessageTo(channel: String, lastMessageUUID: String) -> CentrifugoClientMessage {
            return buildSubscribeWithRecoveryHandler(channel, lastMessageUUID)
        }
        
        var buildUnsubscribeHandler: ( String -> CentrifugoClientMessage )!
        override func buildUnsubscribeMessageFrom(channel: String) -> CentrifugoClientMessage {
            return buildUnsubscribeHandler(channel)
        }
        
        var buildPublishHandler: ( (String, [String : AnyObject]) -> CentrifugoClientMessage )!
        override func buildPublishMessageTo(channel: String, data: [String : AnyObject]) -> CentrifugoClientMessage {
            return buildPublishHandler(channel, data)
        }
        
        var buildHistoryHandler: ( String -> CentrifugoClientMessage )!
        override func buildHistoryMessage(channel: String) -> CentrifugoClientMessage {
            return buildHistoryHandler(channel)
        }
        
        var buildPresenceHandler: ( String -> CentrifugoClientMessage )!
        override func buildPresenceMessage(channel: String) -> CentrifugoClientMessage {
            return buildPresenceHandler(channel)
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
    
    class ClientDelegateMock: CentrifugoClientDelegate {
        var receivedError: NSError?
        
        func client(client: CentrifugoClient, didReceiveRefresh: Any) {
            
        }
        
        func client(client: CentrifugoClient, didDisconnect: Any) {
        }
        
        func client(client: CentrifugoClient, didReceiveError error: NSError) {
            receivedError = error
        }
    }
    
    class ChannelDelegateMock: CentrifugoChannelDelegate {
        var messageHandler: ( (CentrifugoClient, String, CentrifugoServerMessage) -> Void )!
        var joinHandler: ( (CentrifugoClient, String, CentrifugoServerMessage) -> Void )!
        var leaveHandler: ( (CentrifugoClient, String, CentrifugoServerMessage) -> Void )!
        var unsubscribeHandler: ( (CentrifugoClient, String, CentrifugoServerMessage) -> Void )!
        
        func client(client: CentrifugoClient, didReceiveMessageInChannel channel: String, message: CentrifugoServerMessage) {
            messageHandler(client, channel, message)
        }
        
        func client(client: CentrifugoClient, didReceiveJoinInChannel channel: String, message: CentrifugoServerMessage) {
            joinHandler(client, channel, message)
        }
        
        func client(client: CentrifugoClient, didReceiveLeaveInChannel channel: String, message: CentrifugoServerMessage) {
            leaveHandler(client, channel, message)
        }
        
        func client(client: CentrifugoClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugoServerMessage) {
            unsubscribeHandler(client, channel, message)
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
