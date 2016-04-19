//
//  Centrifugal.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

public protocol CentrifugoClientMessageBuilder {
    func buildConnectMessage(credentials: CentrifugoCredentials) -> CentrifugoClientMessage
    func buildSubscribeMessageTo(channel: String) -> CentrifugoClientMessage
    func buildUnsubscribeMessageFrom(channel: String) -> CentrifugoClientMessage
    func buildPresenceMessage(channel: String) -> CentrifugoClientMessage
    func buildHistoryMessage(channel: String) -> CentrifugoClientMessage
    func buildPingMessage() -> CentrifugoClientMessage
    func buildPublishMessageTo(channel: String, data: [String: AnyObject]) -> CentrifugoClientMessage
}

public protocol CentrifugoServerMessageParser {
    func parse(data: Any) throws -> [CentrifugoServerMessage]
}

public class Centrifugal {
    public class func messageBuilder() -> CentrifugoClientMessageBuilder {
        return CentrifugoClientMessageBuilderImpl()
    }
    
    public class func messageParser() -> CentrifugoServerMessageParser {
        return CentrifugoServerMessageParserImpl()
    }
}

