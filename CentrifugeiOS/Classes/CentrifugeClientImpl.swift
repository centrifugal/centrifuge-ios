//
//  Clients.swift
//  Pods
//
//  Created by Herman Saprykin on 20/04/16.
//
//

import SwiftWebSocket

typealias CentrifugeBlockingHandler = ([CentrifugeServerMessage]?, NSError?) -> Void

class CentrifugeClientImpl: NSObject, WebSocketDelegate, CentrifugeClient {
    var ws: CentrifugeWebSocket!
    var url: String!
    var creds: CentrifugeCredentials!
    var builder: CentrifugeClientMessageBuilder!
    var parser: CentrifugeServerMessageParser!
    
    weak var delegate: CentrifugeClientDelegate?
    
    var messageCallbacks = [String : CentrifugeMessageHandler]()
    var subscription = [String : CentrifugeChannelDelegate]()
    
    /** Handler is used to process websocket delegate method.
     If it is not nil, it blocks default actions. */
    var blockingHandler: CentrifugeBlockingHandler?
    var connectionCompletion: CentrifugeMessageHandler?
    
    //MARK: - Public interface
    //MARK: Server related method
    func connect(withCompletion completion: @escaping CentrifugeMessageHandler) {
        blockingHandler = connectionProcessHandler
        connectionCompletion = completion
        ws = CentrifugeWebSocket(url)
        ws.delegate = self
    }
    
    func disconnect() {
        ws.delegate = nil
        ws.close()
    }
    
    func ping(withCompletion completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildPingMessage()
        messageCallbacks[message.uid] = completion
        send(message: message)
    }
    
    //MARK: Channel related method
    func subscribe(toChannel channel: String, delegate: CentrifugeChannelDelegate, completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildSubscribeMessageTo(channel: channel)
        subscription[channel] = delegate
        messageCallbacks[message.uid] = completion
        send(message: message)
    }

    func subscribe(toChannel channel: String, delegate: CentrifugeChannelDelegate, lastMessageUID uid: String, completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildSubscribeMessageTo(channel: channel, lastMessageUUID: uid)
        subscription[channel] = delegate
        messageCallbacks[message.uid] = completion
        send(message: message)
    }
    
    func publish(toChannel channel: String, data: [String : Any], completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildPublishMessageTo(channel: channel, data: data)
        messageCallbacks[message.uid] = completion
        send(message: message)
    }
    
    func unsubscribe(fromChannel channel: String, completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildUnsubscribeMessageFrom(channel: channel)
        messageCallbacks[message.uid] = completion
        send(message: message)
    }
    
    func presence(inChannel channel: String, completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildPresenceMessage(channel: channel)
        messageCallbacks[message.uid] = completion
        send(message: message)
    }
    
    func history(ofChannel channel: String, completion: @escaping CentrifugeMessageHandler) {
        let message = builder.buildHistoryMessage(channel: channel)
        messageCallbacks[message.uid] = completion
        send(message: message)
    }
    
    //MARK: - Helpers
    func unsubscribeFrom(channel: String) {
        subscription[channel] = nil
    }
    
    func send(message: CentrifugeClientMessage) {
        try! ws.send(centrifugeMessage: message)
    }
    
    func setupConnectedState() {
        blockingHandler = defaultProcessHandler
    }
    
    func resetState() {
        blockingHandler = nil
        connectionCompletion = nil
        
        messageCallbacks.removeAll()
        subscription.removeAll()
    }
    
    //MARK: - Handlers
    /**
     Handler is using while connecting to server.
     */
    func connectionProcessHandler(messages: [CentrifugeServerMessage]?, error: NSError?) -> Void {
        guard let handler = connectionCompletion else {
            assertionFailure("Error: No connectionCompletion")
            return
        }
        
        resetState()
        
        if let err = error {
            handler(nil, err)
            return
        }
        
        guard let message = messages?.first else {
            assertionFailure("Error: Empty messages array")
            return
        }
        
        if message.error == nil{
            setupConnectedState()
            handler(message, nil)
        } else {
            let error = NSError.errorWithMessage(message: message)
            handler(nil, error)
        }
    }
    
    /**
     Handler is using while normal working with server.
     */
    func defaultProcessHandler(messages: [CentrifugeServerMessage]?, error: NSError?) {
        if let err = error {
            delegate?.client(self, didReceiveError: err)
            return
        }
        
        guard let msgs = messages else {
            assertionFailure("Error: Empty messages array without error")
            return
        }
        
        for message in msgs {
            defaultProcessHandler(message: message)
        }
    }
    
    func defaultProcessHandler(message: CentrifugeServerMessage) {
        var handled = false
        if let uid = message.uid, messageCallbacks[uid] == nil {
            assertionFailure("Error: Untracked message is received")
            return
        }
        
        if let uid = message.uid, let handler = messageCallbacks[uid], message.error != nil {
            let error = NSError.errorWithMessage(message: message)
            handler(nil, error)
            messageCallbacks[uid] = nil
            return
        }
        
        if let uid = message.uid, let handler = messageCallbacks[uid] {
            handler(message, nil)
            messageCallbacks[uid] = nil
            handled = true
        }
        
        if (handled && (message.method != .Unsubscribe && message.method != .Disconnect)) {
            return
        }
        
        switch message.method {
            
        // Channel events
        case .Message:
            guard let channel = message.body?["channel"] as? String, let delegate = subscription[channel] else {
                assertionFailure("Error: Invalid \(message.method) handler")
                return
            }
            delegate.client(self, didReceiveMessageInChannel: channel, message: message)
        case .Join:
            guard let channel = message.body?["channel"] as? String, let delegate = subscription[channel] else {
                assertionFailure("Error: Invalid \(message.method) handler")
                return
            }
            delegate.client(self, didReceiveJoinInChannel: channel, message: message)
        case .Leave:
            guard let channel = message.body?["channel"] as? String, let delegate = subscription[channel] else {
                assertionFailure("Error: Invalid \(message.method) handler")
                return
            }
            delegate.client(self, didReceiveLeaveInChannel: channel, message: message)
        case .Unsubscribe:
            guard let channel = message.body?["channel"] as? String, let delegate = subscription[channel] else {
                assertionFailure("Error: Invalid \(message.method) handler")
                return
            }
            delegate.client(self, didReceiveUnsubscribeInChannel: channel, message: message)
            unsubscribeFrom(channel: channel)
            
        // Client events
        case .Disconnect:
            delegate?.client(self, didDisconnect: message)
            ws.close()
            resetState()
        case .Refresh:
            delegate?.client(self, didReceiveRefresh: message)
        default:
            assertionFailure("Error: Invalid method type")
        }
    }
    
    //MARK: - WebSocketDelegate
    func webSocketOpen() {
        let message = builder.buildConnectMessage(credentials: creds)
        send(message: message)
    }
    
    func webSocketMessageText(_ text: String) {
        let data = text.data(using: String.Encoding.utf8)!
        let messages = try! parser.parse(data: data)

        if let handler = blockingHandler {
            handler(messages, nil)
        }
    }
    
    func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {
        if let handler = blockingHandler {
            let error = NSError(domain: CentrifugeWebSocketErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : reason])
            handler(nil, error)
        }
        
    }
    
    func webSocketError(_ error: NSError) {
        if let handler = blockingHandler {
            handler(nil, error)
        }
    }
}

