//
//  WebSocket.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import SwiftWebSocket

class CentrifugeWebSocket: WebSocket {
    func send(message: CentrifugeClientMessage) throws {
        let dict: [String:AnyObject] = ["uid" : message.uid,
                                        "method" : message.method.rawValue,
                                        "params" : message.params]
        let data = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions())

        send(data: data)
    }
}