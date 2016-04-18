//
//  Messages.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import Foundation

public struct CentrifugoClientMessage {
    let uid: String
    let method: CentrifugeMethod
    let params: [String : AnyObject]?
}

public struct CentrifugeServerMessage {
    let uid: String?
    let method: CentrifugeMethod
    let error: String?
    let body: [String : AnyObject]?
}

extension CentrifugoClientMessage: Equatable {}

// MARK: Equatable

public func ==(lhs: CentrifugoClientMessage, rhs: CentrifugoClientMessage) -> Bool {
    return lhs.uid == rhs.uid
}

public struct CentrifugeCredentials {
    let secret : String
    let user : String
    let timestamp : String
}

public enum CentrifugeMethod : String {
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