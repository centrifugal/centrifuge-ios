//
//  CentrifugeClientImplTests.swift
//  CentrifugeiOS
//
//  Created by German Saprykin on 25/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import Starscream
@testable import CentrifugeiOS

class CentrifugeClientImplTests: XCTestCase {
    
    var client: CentrifugeClientImpl!
    var parser: ParserMock!
    
    override func setUp() {
        super.setUp()
        parser = ParserMock()
        
        client = CentrifugeClientImpl()
        client.parser = parser
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: - Public interface
    func testConnectCallsWebSocketOpenAndSetupsHandler() {
        // given
        let url = "https://example.com"
        client.url = url
        
        // when
        client.connect { _,_  in }
        
        // then
        XCTAssertNotNil(client.ws.delegate)
        XCTAssertNotNil(client.ws)
    }
    
    func testPingProcessValid() {
        // given
        var validMessageDidSend = false
        
        let ws = WebSocketMock()
        let builder = BuilderMock()
        
        client.builder = builder
        client.ws = ws
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildPingHandler = {  return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.ping { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
    }
    
    func testDisconnectProcessValid() {
        // given
        var closeDidCall = false
        
        let ws = WebSocketMock()
        client.ws = ws
        ws.delegate = client
        ws.closeHandler = {
            closeDidCall = true
            } as (() -> Void)
        
        // when
        client.disconnect()
        
        // then
        XCTAssertTrue(closeDidCall)
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
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildSubscribeHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.subscribe(toChannel: channel, delegate: delegate) { _, _ in }
        
        // then
        XCTAssertTrue(validMessageDidSend)
        XCTAssertNotNil(client.messageCallbacks[message.uid])
        XCTAssertNotNil(client.subscription[channel])
    }
    
    func testSubscribeWithRecoveryProcessValid() {
        // given
        var validMessageDidSend = false
        let uid = UUID().uuidString
        
        let channel = "channelName"
        let delegate = ChannelDelegateMock()
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let builder = BuilderMock()
        client.builder = builder
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildSubscribeWithRecoveryHandler = { _, _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.subscribe(toChannel: channel, delegate: delegate, lastMessageUID: uid) { _, _ in }
        
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
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildUnsubscribeHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        client.subscription[channel] = ChannelDelegateMock()
        
        // when
        client.unsubscribe(fromChannel: channel) { _, _ in }
        
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
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildHistoryHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.history(ofChannel: channel) { _, _ in }
        
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
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildPresenceHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.presence(inChannel: channel) { _, _ in }
        
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
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildPublishHandler = { _,_  in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.publish(toChannel: channel, data: [:]) { _, _ in }
        
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
        client.defaultProcessHandler(messages: nil, error: expectedError)
        
        // then
        XCTAssertEqual(delegate.receivedError, expectedError)
    }
    
    func testDefaultProcessHandlerProcessMessageWithError() {
        // given
        let channel = "myChannel"
        
        let message = CentrifugeServerMessage(uid: UUID().uuidString, method: .publish, error: "decription", body: ["channel":channel])
        
        var receivedMessage: CentrifugeServerMessage?
        var receivedError: NSError?
        
        client.messageCallbacks[message.uid!] = { message, error in
            receivedMessage = message
            receivedError = error
        }
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertNil(receivedMessage)
        XCTAssertNotNil(receivedError)
        XCTAssertNil(client.messageCallbacks[message.uid!])
    }
    
    func testDefaultProcessHandlerCallsMessageCallbacksAndRemoveCallback() {
        // given
        let expectedMessage = CentrifugeServerMessage.testMessage()
        var receivedMessage: CentrifugeServerMessage!
        
        client.messageCallbacks[expectedMessage.uid!] = { message, _ in
            receivedMessage = message
        }
        
        // when
        client.defaultProcessHandler(messages: [expectedMessage], error: nil)
        
        // then
        XCTAssertEqual(expectedMessage, receivedMessage)
        XCTAssertNil(client.messageCallbacks[expectedMessage.uid!])
    }
    
    func testDefaultProcessHandlerCallsMessageChannelDelegate() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        
        let message = CentrifugeServerMessage(uid: nil, method: .message, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.messageHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertEqual(expectedChannel, receivedChannel)
    }
    
    func testDefaultProcessHandlerProcessesDisconnect() {
        // given
        let message = CentrifugeServerMessage(uid: nil, method: .disconnect, error: nil, body: [ : ])
        var closeDidCall = false
        let delegate = ClientDelegateMock()
        client.delegate = delegate
        
        client.subscription["2"] = ChannelDelegateMock()
        client.subscription["1"] = ChannelDelegateMock()
        client.messageCallbacks["1"] = { _, _ in }
        let ws = WebSocketMock()
        client.ws = ws
        
        ws.closeHandler = {
            closeDidCall = true
            } as (() -> Void)
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertTrue(delegate.disconnectDidCall)
        XCTAssertTrue(closeDidCall)
        XCTAssertEqual(client.subscription.count, 0)
        XCTAssertEqual(client.messageCallbacks.count, 0)
    }
    
    func testDefaultProcessHandlerCallsRefreshClientDelegate() {
        // given
        let message = CentrifugeServerMessage(uid: nil, method: .refresh, error: nil, body: [ : ])
        
        let delegate = ClientDelegateMock()
        client.delegate = delegate
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertTrue(delegate.refreshtDidCall)
    }
    
    func testDefaultProcessHandlerCallsJoinChannelDelegate() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        
        let message = CentrifugeServerMessage(uid: nil, method: .join, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.joinHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertEqual(expectedChannel, receivedChannel)
    }
    
    func testDefaultProcessHandlerCallsLeaveChannelDelegate() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        
        let message = CentrifugeServerMessage(uid: nil, method: .leave, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.leaveHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertEqual(expectedChannel, receivedChannel)
    }
    
    func testDefaultProcessHandlerCallsUnsubscribeChannelDelegateAndHandler() {
        // given
        let expectedChannel = "myChannel"
        var receivedChannel = ""
        var handlerCalled = false
        let uid = UUID().uuidString
        
        let message = CentrifugeServerMessage(uid: uid, method: .unsubscribe, error: nil, body: ["channel" : expectedChannel])
        
        let delegate = ChannelDelegateMock()
        delegate.unsubscribeHandler = { _, channel, _ in
            receivedChannel = channel
        }
        
        client.subscription[expectedChannel] = delegate
        client.messageCallbacks[uid] = { _, _ in
            handlerCalled = true
        }
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssert(handlerCalled)
        XCTAssertEqual(expectedChannel, receivedChannel)
        XCTAssertNil(client.subscription[expectedChannel])
    }
    
    func testDefaultProcessHandlerCallsDisconnectChannelDelegateAndHandler() {
        // given
        var handlerCalled = false
        let uid = UUID().uuidString
        
        let message = CentrifugeServerMessage(uid: uid, method: .disconnect, error: nil, body: [ : ])
        
        let delegate = ClientDelegateMock()
        
        client.delegate = delegate
        client.messageCallbacks[uid] = { _, _ in
            handlerCalled = true
        }
        
        client.ws = WebSocketMock()
        
        // when
        client.defaultProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertTrue(handlerCalled)
        XCTAssertTrue(delegate.disconnectDidCall)
        XCTAssertNil(client.messageCallbacks[uid])
    }
    
    func testConnectionProcessHandlerResetsStateIfError() {
        // given
        let error = NSError(domain: "", code: 1, userInfo: nil)
        
        client.connectionCompletion = { _, _  in}
        client.blockingHandler = client.connectionProcessHandler
        
        // when
        client.connectionProcessHandler(messages: nil, error: error)
        
        // then
        XCTAssertNil(client.blockingHandler)
        XCTAssertNil(client.connectionCompletion)
    }
    
    func testConnectionProcessHandlerProcessError() {
        // given
        var receivedError: NSError?
        let expectedError = NSError(domain: "", code: 1, userInfo: nil)
        
        client.connectionCompletion = { _, error in
            receivedError = error
        }
        
        // when
        client.connectionProcessHandler(messages: nil, error: expectedError)
        
        // then
        XCTAssertEqual(receivedError, expectedError)
    }
    
    func testConnectionProcessHandlerProcessValidMessage() {
        // given
        var handlerCalled = false
        var receivedError: NSError?
        
        client.connectionCompletion = { _, error in
            handlerCalled = true
            receivedError = error
        }
        
        // when
        client.connectionProcessHandler(messages: [CentrifugeServerMessage.testMessage()], error: nil)
        
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
        let message = CentrifugeServerMessage.errorMessage(desc)
        client.connectionCompletion = { _, error in
            handlerCalled = true
            receivedError = error
        }
        
        // when
        client.connectionProcessHandler(messages: [message], error: nil)
        
        // then
        XCTAssertEqual(receivedError.code, CentrifugeErrorCode.CentrifugeMessageWithError.rawValue)
        XCTAssertEqual(receivedError.domain, CentrifugeErrorDomain)
        XCTAssertEqual(receivedError.localizedDescription, desc)
        if let wrapper = receivedError.userInfo[CentrifugeErrorMessageKey] as? CentrifugeWrapper<CentrifugeServerMessage> {
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
        client.creds = CentrifugeCredentials.testCreds()
        
        let builder = BuilderMock()
        client.builder = builder
        
        let ws = WebSocketMock()
        client.ws = ws
        
        let message = CentrifugeClientMessage.testMessage()
        
        builder.buildConnectHandler = { _ in return message }
        
        ws.sendHandler = { aMessage in
            validMessageDidSend = (aMessage == message)
        }
        
        // when
        client.websocketDidConnect(socket: ws)
        
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
        client.websocketDidReceiveMessage(socket: WebSocketMock(), text: "")
        
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
        client.websocketDidReceiveMessage(socket: WebSocketMock(), text: text)
        
        // then
        XCTAssertTrue(handlerCalled)
    }
    
    func testClientWebSocketMessageDataSentValidMessage() {
        // given
        var validMessagesDidReceive = false
        let messages = [CentrifugeServerMessage.testMessage()]
        
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
        client.websocketDidReceiveMessage(socket: WebSocketMock(), text: text)
        
        // then
        XCTAssertTrue(validMessagesDidReceive)
    }
    
    func testClientWebSocketCloseUsesHandler() {
        // given
        var handlerCalled = false
        var receivedError: Error?
        
        client.blockingHandler = { _, error in
            handlerCalled = true
            receivedError = error
        }
        
        // when
        client.websocketDidDisconnect(socket: WebSocketMock(), error: nil)
        
        // then
        XCTAssertTrue(handlerCalled)
        XCTAssertNil(receivedError)
    }
    
    func testClientWebSocketErrorUsesHandler() {
        // given
        var handlerCalled = false
        var receivedError: NSError?
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Hello"])
        
        client.blockingHandler = { _, error in
            handlerCalled = true
            receivedError = error
        }
        // when
        client.websocketDidDisconnect(socket: WebSocketMock(), error: error)
        
        // then
        XCTAssertTrue(handlerCalled)
        XCTAssertEqual(receivedError?.localizedDescription, "Hello")
    }
    
    //MARK: - Helpers
    class WebSocketMock: WebSocket {
        var openHandler: (() -> Void)?
        var closeHandler: (() -> Void)?
        var sendHandler: ((CentrifugeClientMessage) -> Void)?
        
        init() {
            let url = URL(string:"https://example.com")!
            let request = URLRequest(url: url)
            super.init(request: request)
        }
        
        
        override func connect() {
            openHandler?()
        }
        
        override func disconnect(forceTimeout: TimeInterval? = nil, closeCode: UInt16 = CloseCode.normal.rawValue) {
            closeHandler?()
        }
        
        override func write(data: Data, completion: (() -> ())? = nil) {
            let dict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let message = CentrifugeClientMessage(uid: dict["uid"] as! String, method: CentrifugeMethod(rawValue: dict["method"] as! String)!, params: dict["params"] as! [String:Any])
            sendHandler?(message)
        }
    }
    
    class BuilderMock: CentrifugeClientMessageBuilderImpl {
        var buildConnectHandler: ( (CentrifugeCredentials) -> CentrifugeClientMessage )!
        override func buildConnectMessage(credentials: CentrifugeCredentials) -> CentrifugeClientMessage {
            return buildConnectHandler(credentials)
        }
        
        var buildPingHandler: ( () -> CentrifugeClientMessage )!
        override func buildPingMessage() -> CentrifugeClientMessage {
            return buildPingHandler()
        }
        
        var buildDisconnectHandler: ( () -> CentrifugeClientMessage )!
        override func buildDisconnectMessage() -> CentrifugeClientMessage {
            return buildDisconnectHandler()
        }
        
        var buildSubscribeHandler: ( (String) -> CentrifugeClientMessage )!
        override func buildSubscribeMessageTo(channel: String) -> CentrifugeClientMessage {
            return buildSubscribeHandler(channel)
        }
        
        var buildSubscribeWithRecoveryHandler: ( (String, String) -> CentrifugeClientMessage )!
        override func buildSubscribeMessageTo(channel: String, lastMessageUUID: String) -> CentrifugeClientMessage {
            return buildSubscribeWithRecoveryHandler(channel, lastMessageUUID)
        }
        
        var buildUnsubscribeHandler: ( (String) -> CentrifugeClientMessage )!
        override func buildUnsubscribeMessageFrom(channel: String) -> CentrifugeClientMessage {
            return buildUnsubscribeHandler(channel)
        }
        
        var buildPublishHandler: ( (String, [String : Any]) -> CentrifugeClientMessage )!
        override func buildPublishMessageTo(channel: String, data: [String : Any]) -> CentrifugeClientMessage {
            return buildPublishHandler(channel, data)
        }
        
        var buildHistoryHandler: ( (String) -> CentrifugeClientMessage )!
        override func buildHistoryMessage(channel: String) -> CentrifugeClientMessage {
            return buildHistoryHandler(channel)
        }
        
        var buildPresenceHandler: ( (String) -> CentrifugeClientMessage )!
        override func buildPresenceMessage(channel: String) -> CentrifugeClientMessage {
            return buildPresenceHandler(channel)
        }
    }
    
    class ParserMock: CentrifugeServerMessageParserImpl {
        var parseHandler: ( (Data) -> [CentrifugeServerMessage] )?
        override func parse(data: Data) throws -> [CentrifugeServerMessage] {
            if let handler = parseHandler {
                return handler(data)
            } else {
                return []
            }
        }
    }
    
    class ClientDelegateMock: CentrifugeClientDelegate {
        var receivedError: NSError?
        
        var disconnectDidCall = false
        var disconnectMessage:CentrifugeServerMessage!
        
        var refreshtDidCall = false
        var refreshMessage:CentrifugeServerMessage!
        
        func client(_ client: CentrifugeClient, didReceiveRefresh message: CentrifugeServerMessage) {
            refreshtDidCall = true
            refreshMessage = message
        }
        
        func client(_ client: CentrifugeClient, didDisconnect message: CentrifugeServerMessage) {
            disconnectDidCall = true
            disconnectMessage = message
        }
        
        func client(_ client: CentrifugeClient, didReceiveError error: NSError) {
            receivedError = error
        }
    }
    
    class ChannelDelegateMock: CentrifugeChannelDelegate {
        var messageHandler: ( (CentrifugeClient, String, CentrifugeServerMessage) -> Void )!
        var joinHandler: ( (CentrifugeClient, String, CentrifugeServerMessage) -> Void )!
        var leaveHandler: ( (CentrifugeClient, String, CentrifugeServerMessage) -> Void )!
        var unsubscribeHandler: ( (CentrifugeClient, String, CentrifugeServerMessage) -> Void )!
        
        func client(_ client: CentrifugeClient, didReceiveMessageInChannel channel: String, message: CentrifugeServerMessage) {
            messageHandler(client, channel, message)
        }
        
        func client(_ client: CentrifugeClient, didReceiveJoinInChannel channel: String, message: CentrifugeServerMessage) {
            joinHandler(client, channel, message)
        }
        
        func client(_ client: CentrifugeClient, didReceiveLeaveInChannel channel: String, message: CentrifugeServerMessage) {
            leaveHandler(client, channel, message)
        }
        
        func client(_ client: CentrifugeClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugeServerMessage) {
            unsubscribeHandler(client, channel, message)
        }
    }
}

extension CentrifugeClientMessage {
    static func testMessage() -> CentrifugeClientMessage {
        return CentrifugeClientMessage(uid: NSUUID().uuidString, method: .сonnect, params: [:])
    }
}

extension CentrifugeServerMessage {
    static func testMessage() -> CentrifugeServerMessage {
        return CentrifugeServerMessage(uid: NSUUID().uuidString, method: .сonnect, error: nil, body: [:])
    }
    static func errorMessage(_ decription: String) -> CentrifugeServerMessage {
        return CentrifugeServerMessage(uid: NSUUID().uuidString, method: .сonnect, error: decription, body: [:])
    }
}

extension CentrifugeCredentials {
    static func testCreds() -> CentrifugeCredentials {
        return CentrifugeCredentials(token: "testToken", user: "testUser", timestamp: "1234567898")
    }
}
