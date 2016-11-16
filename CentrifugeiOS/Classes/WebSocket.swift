//
//  WebSocket.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

import SwiftWebSocket

class CentrifugeWebSocket: WebSocket {
    
    func send(centrifugeMessage message: CentrifugeClientMessage) throws {
        let dict: [String:Any] = ["uid" : message.uid,
                                  "method" : message.method.rawValue,
                                  "params" : message.params]
        let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions())
        
        send(data: data)
    }
}
