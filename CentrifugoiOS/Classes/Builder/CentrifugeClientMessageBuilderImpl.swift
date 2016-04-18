//
//  CentrifugoClientMessageBuilderImpl.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import Foundation
import IDZSwiftCommonCrypto

class CentrifugoClientMessageBuilderImpl: CentrifugoClientMessageBuilder {
    
    func buildConnectMessage(credentials: CentrifugeCredentials) -> CentrifugoClientMessage {
        
        let user = credentials.user, timestamp = credentials.timestamp, secret = credentials.secret
        
        let params = ["user" : user,
                      "timestamp" : timestamp,
                      "token" : createToken("\(user)\(timestamp)", key: secret)]
        
        return buildMessage(.Connect, params: params)
    }
    
    func buildSubscribeMessage(channel: String) -> CentrifugoClientMessage {
        let params = ["channel" : channel]
        return buildMessage(.Subscribe, params: params)
    }
    
    func buildUnsubscribeMessage(channel: String) -> CentrifugoClientMessage {
        let params = ["channel" : channel]
        return buildMessage(.Unsubscribe, params: params)
    }
    
    func buildPublishMessage(channel: String, data: [String : AnyObject]) -> CentrifugoClientMessage {
        let params:[String : AnyObject] = ["channel" : channel,
                                           "data" : data]
        return buildMessage(.Publish, params: params)
    }
    
    private func buildMessage(method: CentrifugeMethod, params: [String: AnyObject]?) -> CentrifugoClientMessage {
        let uid = generateUUID()
        let message = CentrifugoClientMessage(uid: uid, method: method, params: params)
        return message
    }
    
    private func generateUUID() -> String {
        return NSUUID().UUIDString
    }
    
    private func createToken(string: String, key: String) -> String {
        let keys5 = arrayFromHexString(key)
        let datas5 = arrayFromHexString(string)
        let hmacs5 = HMAC(algorithm:.SHA1, key:keys5).update(datas5)?.final()
        let token = hexStringFromArray(hmacs5!)
        return token
    }
}