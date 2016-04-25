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
    func parse(data: NSData) throws -> [CentrifugoServerMessage]
}

public class Centrifugal {
    public class func client(url: String, creds: CentrifugoCredentials) -> CentrifugoClient {
        let client = CentrifugoClientImpl()
        client.ws = CentrifugoWebSocket(url)
        client.builder = CentrifugoClientMessageBuilderImpl()
        client.parser = CentrifugoServerMessageParserImpl()
        client.creds = creds
        // TODO: Check references cycle
        client.ws.delegate = client
        
        return client
    }
}

let CentrifugoErrorDomain = "com.centrifugo.error.domain"
let CentrifugoErrorMessageKey = "com.centrifugo.error.messagekey"

enum CentrifugoErrorCode: Int {
    case CentrifugoMessageWithError
}