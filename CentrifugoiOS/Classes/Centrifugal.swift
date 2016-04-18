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
    func buildPublishMessageTo(channel: String, data: [String: AnyObject]) -> CentrifugoClientMessage
}

public class Centrifugal {
    public class func messageBuilder() -> CentrifugoClientMessageBuilder {
        return CentrifugoClientMessageBuilderImpl()
    }
    
    public class func messagesParser(handler: ([CentrifugoServerMessage]) -> Void) -> (Any) -> Void {
        return { message in
            guard let text = message as? String else {
                print("Error: Invalid server response: Not string")
                return
            }
            
            guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {
                print("Error: Invalid server response: Not valid string")
                return
            }
            
            do {
                let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                var messages = [CentrifugoServerMessage]()
                
                if let infos = response as? [[String : AnyObject]] {
                    for info in infos {
                        if let message = messageParse(info){
                            messages.append(message)
                        }
                    }
                }
                
                if let info = response as? [String : AnyObject] {
                    if let message = messageParse(info){
                        messages.append(message)
                    }
                }
                
                handler(messages)
                
            } catch let error as NSError{
                print(error)
                return
            }
        }
    }
}

func messageParse(info: [String : AnyObject]) -> CentrifugoServerMessage? {
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
    
    guard let method = CentrifugoMethod(rawValue: methodName) else {
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
    
    return CentrifugoServerMessage(uid: uid, method: method, error: error, body: body)
}