//
//  Clients.swift
//  Pods
//
//  Created by Herman Saprykin on 20/04/16.
//
//

import SwiftWebSocket

typealias CentrifugoBlockingHandler = ([CentrifugoServerMessage]?, NSError?) -> Void
typealias CentrifugoHandler = (Void -> Void)
public typealias CentrifugoErrorHandler = (NSError? -> Void)

protocol CentrifugoClientDelegate {
    func client(client: CentrifugoClient, didReceiveError:ErrorType)
    func client(client: CentrifugoClient, didReceiveRefresh: Any)
    func client(client: CentrifugoClient, didDisconnect: Any)
}

public protocol CentrifugoClient {
    func connect(completion: CentrifugoErrorHandler)
}

protocol CentrifugoClientUnimplemented {
    func disconnect(completion: CentrifugoErrorHandler)
    func ping(completion: CentrifugoErrorHandler)
    
    var delegate: CentrifugoClientDelegate? {get set}
    var connected: Bool {get}
    
    func subscribe(channel: String, delegate: Any, completion: Any)
    func unsubscribe(channel: String, completion: CentrifugoErrorHandler)
}

class CentrifugoClientImpl: NSObject, WebSocketDelegate, CentrifugoClient {
    var ws: CentrifugoWebSocket!
    var creds: CentrifugoCredentials!
    var builder: CentrifugoClientMessageBuilder!
    var parser: CentrifugoServerMessageParser!
    
    var delegate: CentrifugoClientDelegate!
    
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
    
    //MARK: - Helpers
    func setupConnectedState() {
        
    }
    
    func resetState() {
        blockingHandler = nil
        connectionCompletion = nil
    }
    
    //MARK: - Handlers
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
            handler(nil)
        } else {
            let error = NSError.errorWithMessage(message)
            handler(error)
        }
        
    }
    
    //MARK: - WebSocketDelegate
    func webSocketOpen() {
        let message = builder.buildConnectMessage(creds)
        try! ws.send(message)
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
            handler(nil, nil)
        }
        
    }
    
    func webSocketError(error: NSError) {
        if let handler = blockingHandler {
            handler(nil, nil)
        }        
    }
}

