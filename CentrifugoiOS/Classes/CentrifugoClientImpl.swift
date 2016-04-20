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

public struct CentrifugoClientEvents {
    let onError: CentrifugoErrorHandler?
    let onRefresh: CentrifugoHandler?
    let onDisconnect: CentrifugoErrorHandler?
    
    public init(error: CentrifugoErrorHandler? = nil, refresh: CentrifugoHandler? = nil, disconnect: CentrifugoErrorHandler? = nil) {
        onError = error
        onRefresh = refresh
        onDisconnect = disconnect
    }
}

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

protocol CentrifugoClient {
    func connect(completion: CentrifugoErrorHandler)
    func disconnect(completion: CentrifugoErrorHandler)
    func ping(completion: CentrifugoErrorHandler)
    
    var events: CentrifugoClientEvents? {get set}
    var connected: Bool {get}
    
    func subscribe(channel: String, events: CentrifugoSubscriptionEvents?, completion: Any)
    func unsubscribe(channel: String, completion: CentrifugoErrorHandler)
}

class CentrifugoClientImpl {
}

