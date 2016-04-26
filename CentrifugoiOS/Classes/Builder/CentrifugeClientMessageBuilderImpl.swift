//
//  CentrifugoClientMessageBuilderImpl.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import IDZSwiftCommonCrypto

protocol CentrifugoClientMessageBuilder {
    func buildConnectMessage(credentials: CentrifugoCredentials) -> CentrifugoClientMessage
    func buildDisconnectMessage() -> CentrifugoClientMessage
    func buildSubscribeMessageTo(channel: String) -> CentrifugoClientMessage
    func buildSubscribeMessageTo(channel: String, lastMessageUUID: String) -> CentrifugoClientMessage
    func buildUnsubscribeMessageFrom(channel: String) -> CentrifugoClientMessage
    func buildPresenceMessage(channel: String) -> CentrifugoClientMessage
    func buildHistoryMessage(channel: String) -> CentrifugoClientMessage
    func buildPingMessage() -> CentrifugoClientMessage
    func buildPublishMessageTo(channel: String, data: [String: AnyObject]) -> CentrifugoClientMessage
}

class CentrifugoClientMessageBuilderImpl: CentrifugoClientMessageBuilder {
    
    func buildConnectMessage(credentials: CentrifugoCredentials) -> CentrifugoClientMessage {
        
        let user = credentials.user, timestamp = credentials.timestamp, secret = credentials.secret
        
        var params = ["user" : user,
                      "timestamp" : timestamp,
                      "token" : createToken("\(user)\(timestamp)", key: secret)]
        
        if let info = credentials.info {
            params["info"] = info
        }
        
        return buildMessage(.Connect, params: params)
    }
    
    func buildDisconnectMessage() -> CentrifugoClientMessage {
        return buildMessage(.Disconnect, params: [:])
    }
    
    func buildSubscribeMessageTo(channel: String) -> CentrifugoClientMessage {
        let params = ["channel" : channel]
        return buildMessage(.Subscribe, params: params)
    }
    
    func buildSubscribeMessageTo(channel: String, lastMessageUUID: String) -> CentrifugoClientMessage {
        let params = ["channel" : channel,
                      "recover" : true,
                      "last" : lastMessageUUID]
        return buildMessage(.Subscribe, params: params as! [String : AnyObject])
    }
    
    func buildUnsubscribeMessageFrom(channel: String) -> CentrifugoClientMessage {
        let params = ["channel" : channel]
        return buildMessage(.Unsubscribe, params: params)
    }
    
    func buildPublishMessageTo(channel: String, data: [String : AnyObject]) -> CentrifugoClientMessage {
        let params:[String : AnyObject] = ["channel" : channel,
                                           "data" : data]
        return buildMessage(.Publish, params: params)
    }
    
    func buildPresenceMessage(channel: String) -> CentrifugoClientMessage {
        let params:[String : AnyObject] = ["channel" : channel]
        return buildMessage(.Presence, params: params)
    }
    
    func buildHistoryMessage(channel: String) -> CentrifugoClientMessage {
        let params:[String : AnyObject] = ["channel" : channel]
        return buildMessage(.History, params: params)
    }
    
    func buildPingMessage() -> CentrifugoClientMessage {
        return buildMessage(.Ping, params: [:])
    }
    
    private func buildMessage(method: CentrifugoMethod, params: [String: AnyObject]) -> CentrifugoClientMessage {
        let uid = generateUUID()
        let message = CentrifugoClientMessage(uid: uid, method: method, params: params)
        return message
    }
    
    private func generateUUID() -> String {
        return NSUUID().UUIDString
    }
    
    private func createToken(string: String, key: String) -> String {
        let hexKey = hexadecimalStringFromData(key.dataUsingEncoding(NSUTF8StringEncoding)!)
        let hexString = hexadecimalStringFromData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let keys5 = arrayFromHexString(hexKey)
        let datas5 = arrayFromHexString(hexString)
        
        let hmacs5 = HMAC(algorithm:.SHA256, key:keys5).update(datas5)?.final()
        let token = hexStringFromArray(hmacs5!)
        return token
    }
    
    private func hexadecimalStringFromData(data: NSData) -> String{
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return String(hexString)
    }
}