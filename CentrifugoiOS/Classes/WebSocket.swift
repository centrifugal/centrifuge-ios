//
//  WebSocket.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import SwiftWebSocket

class CentrifugoWebSocket: WebSocket {
    public func send(message: CentrifugoClientMessage) throws {
        let dict: [String:AnyObject] = ["uid" : message.uid,
                                        "method" : message.method.rawValue,
                                        "params" : message.params]
        let data = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
        print(message.uid)
        send(data: data)
    }
}