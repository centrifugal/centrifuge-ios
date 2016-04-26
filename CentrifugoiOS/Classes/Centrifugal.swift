//
//  Centrifugal.swift
//  Pods
//
//  Created by Herman Saprykin on 18/04/16.
//
//

public let CentrifugoErrorDomain = "com.centrifugo.error.domain"
public let CentrifugoWebSocketErrorDomain = "com.centrifugo.error.domain.websocket"
public let CentrifugoErrorMessageKey = "com.centrifugo.error.messagekey"

public enum CentrifugoErrorCode: Int {
    case CentrifugoMessageWithError
}

public typealias CentrifugoMessageHandler = (CentrifugoServerMessage?, NSError?) -> Void

public class Centrifugal {
    public class func client(url: String, creds: CentrifugoCredentials, delegate: CentrifugoClientDelegate) -> CentrifugoClient {
        let client = CentrifugoClientImpl()
        client.builder = CentrifugoClientMessageBuilderImpl()
        client.parser = CentrifugoServerMessageParserImpl()
        client.creds = creds
        client.url = url
        // TODO: Check references cycle
        client.delegate = delegate
        
        return client
    }
}