//
//  CentrifugeClientMessageBuilderImpl.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//


protocol CentrifugeClientMessageBuilder {
    func buildConnectMessage(credentials: CentrifugeCredentials) -> CentrifugeClientMessage
    func buildDisconnectMessage() -> CentrifugeClientMessage
    func buildSubscribeMessageTo(channel: String) -> CentrifugeClientMessage
    func buildSubscribeMessageTo(channel: String, lastMessageUUID: String) -> CentrifugeClientMessage
    func buildUnsubscribeMessageFrom(channel: String) -> CentrifugeClientMessage
    func buildPresenceMessage(channel: String) -> CentrifugeClientMessage
    func buildHistoryMessage(channel: String) -> CentrifugeClientMessage
    func buildPingMessage() -> CentrifugeClientMessage
    func buildPublishMessageTo(channel: String, data: [String: Any]) -> CentrifugeClientMessage
}

class CentrifugeClientMessageBuilderImpl: CentrifugeClientMessageBuilder {
    
    func buildConnectMessage(credentials: CentrifugeCredentials) -> CentrifugeClientMessage {
        
        let user = credentials.user, timestamp = credentials.timestamp, token = credentials.token
        
        var params = ["user" : user,
                      "timestamp" : timestamp,
                      "token" : token]
        
        if let info = credentials.info {
            params["info"] = info
        }
        
        return buildMessage(method: .Connect, params: params)
    }
    
    func buildDisconnectMessage() -> CentrifugeClientMessage {
        return buildMessage(method: .Disconnect, params: [:])
    }
    
    func buildSubscribeMessageTo(channel: String) -> CentrifugeClientMessage {
        let params = ["channel" : channel]
        return buildMessage(method: .Subscribe, params: params)
    }
    
    func buildSubscribeMessageTo(channel: String, lastMessageUUID: String) -> CentrifugeClientMessage {
        let params: [String : Any] = ["channel" : channel,
                      "recover" : true,
                      "last" : lastMessageUUID]
        return buildMessage(method: .Subscribe, params: params)
    }
    
    func buildUnsubscribeMessageFrom(channel: String) -> CentrifugeClientMessage {
        let params = ["channel" : channel]
        return buildMessage(method: .Unsubscribe, params: params)
    }
    
    func buildPublishMessageTo(channel: String, data: [String : Any]) -> CentrifugeClientMessage {
        let params = ["channel" : channel,
                      "data" : data] as [String : Any]
        return buildMessage(method: .Publish, params: params)
    }
    
    func buildPresenceMessage(channel: String) -> CentrifugeClientMessage {
        let params = ["channel" : channel]
        return buildMessage(method: .Presence, params: params)
    }
    
    func buildHistoryMessage(channel: String) -> CentrifugeClientMessage {
        let params = ["channel" : channel]
        return buildMessage(method: .History, params: params)
    }
    
    func buildPingMessage() -> CentrifugeClientMessage {
        return buildMessage(method: .Ping, params: [:])
    }
    
    private func buildMessage(method: CentrifugeMethod, params: [String: Any]) -> CentrifugeClientMessage {
        let uid = generateUUID()
        let message = CentrifugeClientMessage(uid: uid, method: method, params: params)
        return message
    }
    
    private func generateUUID() -> String {
        return NSUUID().uuidString
    }

}
