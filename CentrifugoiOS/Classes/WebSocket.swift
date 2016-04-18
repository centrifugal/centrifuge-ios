//
//  WebSocket.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import SwiftWebSocket

extension WebSocket {
    public func send(message: CentrifugoClientMessage) throws {
        var dict: [String:AnyObject] = ["uid" : message.uid,
                                        "method" : message.method.rawValue]
        if let params = message.params {
            dict["params"] = params
        }
        let data = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())
        
        send(data: data)
    }
}