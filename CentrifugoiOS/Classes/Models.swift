//
//  Messages.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import Foundation

public struct CentrifugoClientMessage {
    public let uid: String
    public let method: CentrifugoMethod
    public let params: [String : AnyObject]?
}

extension CentrifugoClientMessage: Equatable {}

public func ==(lhs: CentrifugoClientMessage, rhs: CentrifugoClientMessage) -> Bool {
    return lhs.uid == rhs.uid
}

public struct CentrifugoServerMessage {
    public let uid: String?
    public let method: CentrifugoMethod
    public let error: String?
    public let body: [String : AnyObject]?
}

public struct CentrifugoCredentials {
    let secret : String
    let user : String
    let timestamp : String
    
    public init(secret: String, user: String, timestamp:String) {
        self.secret = secret
        self.user = user
        self.timestamp = timestamp
    }
}

public enum CentrifugoMethod : String {
    case Connect = "connect"
    case Disconnect = "disconnect"
    case Subscribe = "subscribe"
    case Unsubscribe = "unsubscribe"
    case Publish = "publish"
    case Presence = "presence"
    case History = "history"
    case Join = "join"
    case Leave = "leave"
    case Message = "message"
    case Refresh = "refresh"
    case Ping = "ping"
}