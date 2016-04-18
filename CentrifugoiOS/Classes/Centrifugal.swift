//
//  Centrifugal.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

public protocol CentrifugoClientMessageBuilder {
    func buildConnectMessage(credentials: CentrifugeCredentials) -> CentrifugoClientMessage
    func buildSubscribeMessage(channel: String) -> CentrifugoClientMessage
    func buildUnsubscribeMessage(channel: String) -> CentrifugoClientMessage
    func buildPublishMessage(channel: String, data: [String: AnyObject]) -> CentrifugoClientMessage
}

public class Centrifugal {
    public class func messageBuilder() -> CentrifugoClientMessageBuilder {
        return CentrifugoClientMessageBuilderImpl()
    }
    
    public func messageParse(info: [String : AnyObject]) -> CentrifugeServerMessage? {
        guard let uid = info["uid"] as? String? else {
            print("Error: Invalid server response: Not valid message format")
            print(info)
            return nil
        }
        
        guard let methodName = info["method"] as? String else {
            print("Error: Invalid server response: Not valid message format")
            print(info)
            return nil
        }
        
        guard let method = CentrifugeMethod(rawValue: methodName) else {
            print("Error: Invalid server response: Not valid message format")
            print(info)
            return nil
        }
        var error: String?
        
        if let err = info["error"] as? String {
            error = err
        }
        
        var body: [String: AnyObject]?
        
        if let bd = info["body"] as? [String : AnyObject] {
            body = bd
        }
        
        return CentrifugeServerMessage(uid: uid, method: method, error: error, body: body)
    }

}

