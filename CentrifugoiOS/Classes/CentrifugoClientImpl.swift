//
//  Clients.swift
//  Pods
//
//  Created by Herman Saprykin on 20/04/16.
//
//

import SwiftWebSocket

typealias CentrifugoBlockingHandler = ([CentrifugoServerMessage]?, NSError?) -> Void
public typealias CentrifugoMessageHandler = (CentrifugoServerMessage?, NSError?) -> Void
typealias CentrifugoHandler = (Void -> Void)
public typealias CentrifugoErrorHandler = (NSError? -> Void)

public protocol CentrifugoClientDelegate {
    func client(client: CentrifugoClient, didReceiveError error:NSError)
    func client(client: CentrifugoClient, didReceiveRefresh: Any)
    func client(client: CentrifugoClient, didDisconnect: Any)
}

public protocol CentrifugoChannelDelegate {
    func client(client: CentrifugoClient, didReceiveMessageInChannel channel: String, message: CentrifugoServerMessage)
    func client(client: CentrifugoClient, didReceiveJoinInChannel channel: String, message: CentrifugoServerMessage)
}

public protocol CentrifugoClient {
    func connect(completion: CentrifugoErrorHandler)
    func subscribe(channel: String, delegate: CentrifugoChannelDelegate, completion: CentrifugoMessageHandler)
}

protocol CentrifugoClientUnimplemented {
    func disconnect(completion: CentrifugoErrorHandler)
    func ping(completion: CentrifugoErrorHandler)
    
    var delegate: CentrifugoClientDelegate? {get set}
    var connected: Bool {get}
    
    func unsubscribe(channel: String, completion: CentrifugoErrorHandler)
}

class CentrifugoClientImpl: NSObject, WebSocketDelegate, CentrifugoClient {
    var ws: CentrifugoWebSocket!
    var creds: CentrifugoCredentials!
    var builder: CentrifugoClientMessageBuilder!
    var parser: CentrifugoServerMessageParser!
    
    var delegate: CentrifugoClientDelegate!
    
    var messageCallbacks = [String : CentrifugoMessageHandler]()
    var subscription = [String : CentrifugoChannelDelegate]()
    
    /** Handler is used to process websocket delegate method.
     If it is not nil, it blocks default actions. */
    var blockingHandler: CentrifugoBlockingHandler?
    var connectionCompletion: CentrifugoErrorHandler?
    
    //MARK: - Public interface
    func connect(completion: CentrifugoErrorHandler) {
        blockingHandler = connectionProcessHandler
        connectionCompletion = completion
        
        ws.open()
    }
    
    func subscribe(channel: String, delegate: CentrifugoChannelDelegate, completion: CentrifugoMessageHandler) {
        let message = builder.buildSubscribeMessageTo(channel)
        
        subscription[channel] = delegate
        messageCallbacks[message.uid] = completion
        
        send(message)
    }
    
    //MARK: - Helpers
    func send(message: CentrifugoClientMessage) {
        try! ws.send(message)
    }
    
    func setupConnectedState() {
        blockingHandler = defaultProcessHandler
    }
    
    func resetState() {
        blockingHandler = nil
        connectionCompletion = nil
    }
    
    //MARK: - Handlers
    /**
     Handler is using while connecting to server.
     */
    func connectionProcessHandler(messages: [CentrifugoServerMessage]?, error: NSError?) -> Void {
        guard let handler = connectionCompletion else {
            assertionFailure("Error: No connectionCompletion")
            return
        }
        
        resetState()
        
        if let err = error {
            handler(err)
            return
        }
        
        guard let message = messages?.first else {
            assertionFailure("Error: Empty messages array")
            return
        }
        
        if message.error == nil{
            setupConnectedState()
            handler(nil)
        } else {
            let error = NSError.errorWithMessage(message)
            handler(error)
        }
    }
    
    /**
     Handler is using while normal working with server.
     */
    func defaultProcessHandler(messages: [CentrifugoServerMessage]?, error: NSError?) {
        if let err = error {
            delegate.client(self, didReceiveError: err)
            return
        }
        
        guard let msgs = messages else {
            assertionFailure("Error: Empty messages array without error")
            return
        }
        
        for message in msgs {
            defaultProcessHandler(message)
        }
    }
    
    func defaultProcessHandler(message: CentrifugoServerMessage) {
        if let uid = message.uid, handler = messageCallbacks[uid] {
            handler(message, nil)
            messageCallbacks[uid] = nil
            return
        }
        
        switch message.method {
        case .Message:
            if let channel = message.body?["channel"] as? String, delegate = subscription[channel] {
                delegate.client(self, didReceiveMessageInChannel: channel, message: message)
            }
        case .Join:
            if let channel = message.body?["channel"] as? String, delegate = subscription[channel] {
                delegate.client(self, didReceiveJoinInChannel: channel, message: message)
            }
        default:
            print(message)
            assertionFailure("Error: Invalid method type")
        }
    }
    
    //MARK: - WebSocketDelegate
    func webSocketOpen() {
        let message = builder.buildConnectMessage(creds)
        send(message)
    }
    
    func webSocketMessageText(text: String) {
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)!
        let messages = try! parser.parse(data)
        
        if let handler = blockingHandler {
            handler(messages, nil)
        }
    }
    
    func webSocketClose(code: Int, reason: String, wasClean: Bool) {
        if let handler = blockingHandler {
            let error = NSError(domain: CentrifugoWebSocketErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey : reason])
            handler(nil, error)
        }
        
    }
    
    func webSocketError(error: NSError) {
        if let handler = blockingHandler {
            handler(nil, error)
        }
    }
}

