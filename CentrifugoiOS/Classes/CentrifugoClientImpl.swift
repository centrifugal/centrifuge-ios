//
//  Clients.swift
//  Pods
//
//  Created by Herman Saprykin on 20/04/16.
//
//

import SwiftWebSocket

public typealias CentrifugoErrorHandler = (ErrorType? -> Void)
public typealias CentrifugoHandler = (Void -> Void)


public struct CentrifugoSubscriptionEvents {
    let onJoin: CentrifugoHandler?
    let onMessage: CentrifugoHandler?
    let onLeave: CentrifugoHandler?
    let onUnsubscribe: CentrifugoHandler?
    
    public init(join: CentrifugoHandler? = nil, message: CentrifugoHandler? = nil, leave: CentrifugoHandler? = nil, unsubscribe: CentrifugoHandler? = nil) {
        onJoin = join
        onMessage = message
        onLeave = leave
        onUnsubscribe = unsubscribe
    }
}

protocol CentrifugoClientDelegate {
    func client(client: CentrifugoClient, didReceiveError:ErrorType)
    func client(client: CentrifugoClient, didReceiveRefresh: Any)
    func client(client: CentrifugoClient, didDisconnect: Any)
}

protocol CentrifugoClient {
    func connect(completion: CentrifugoErrorHandler)
    func disconnect(completion: CentrifugoErrorHandler)
    func ping(completion: CentrifugoErrorHandler)
    
    var delegate: CentrifugoClientDelegate? {get set}
    var connected: Bool {get}
    
    func subscribe(channel: String, events: CentrifugoSubscriptionEvents?, completion: Any)
    func unsubscribe(channel: String, completion: CentrifugoErrorHandler)
}

class CentrifugoClientImpl: NSObject, WebSocketDelegate {
    var url: String!
    var ws: CentrifugoWebSocket!
    var creds: CentrifugoCredentials!
    var builder: CentrifugoClientMessageBuilder!
    var delegate: CentrifugoClientDelegate!
    
    func connect(completion: CentrifugoErrorHandler) {
        ws.open()
    }
    
    //MARK: - WebSocketDelegate
    func webSocketOpen() {
        let message = builder.buildConnectMessage(creds)
        try! ws.send(message)
    }
    
    func webSocketClose(code: Int, reason: String, wasClean: Bool) {
        
    }
    
    func webSocketError(error: NSError) {
        
    }
}

