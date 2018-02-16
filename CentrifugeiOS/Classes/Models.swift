//
//  Messages.swift
//  Pods
//
//  Created by German Saprykin on 18/04/16.
//
//

import Foundation

public struct CentrifugeClientMessage {
    public let uid: String
    public let method: CentrifugeMethod
    public let params: [String : Any]
}

extension CentrifugeClientMessage: Equatable {}

public func ==(lhs: CentrifugeClientMessage, rhs: CentrifugeClientMessage) -> Bool {
    return lhs.uid == rhs.uid
}

public struct CentrifugeServerMessage {
    public let uid: String?
    public let method: CentrifugeMethod
    public let error: String?
    public let body: [String : Any]?
}

extension CentrifugeServerMessage: Equatable {}

public func ==(lhs: CentrifugeServerMessage, rhs: CentrifugeServerMessage) -> Bool {
    if let luid = lhs.uid, let ruid = rhs.uid {
        return luid == ruid
    }
    return false
}

public struct CentrifugeCredentials {
    let token : String
    let user : String
    let timestamp : String
    let info: String?
    
    public init(token: String, user: String, timestamp:String, info: String? = nil) {
        self.token = token
        self.user = user
        self.timestamp = timestamp
        self.info = info
    }
}

public enum CentrifugeMethod : String {
    case сonnect = "connect"
    case disconnect = "disconnect"
    case subscribe = "subscribe"
    case unsubscribe = "unsubscribe"
    case publish = "publish"
    case presence = "presence"
    case history = "history"
    case join = "join"
    case leave = "leave"
    case message = "message"
    case refresh = "refresh"
    case ping = "ping"
}

class CentrifugeWrapper<T> {
    var value: T
    init(theValue: T) {
        value = theValue
    }
}

extension NSError {
    static func errorWithMessage(message: CentrifugeServerMessage) -> NSError {
        let error = NSError(domain: CentrifugeErrorDomain,
                            code: CentrifugeErrorCode.CentrifugeMessageWithError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey : message.error ?? "", CentrifugeErrorMessageKey : CentrifugeWrapper(theValue: message)])
        return error
    }
}
