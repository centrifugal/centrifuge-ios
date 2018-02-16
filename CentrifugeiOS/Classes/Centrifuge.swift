//
//  Centrifugal.swift
//  Pods
//
//  Created by German Saprykin on 18/04/16.
//
//

import IDZSwiftCommonCrypto

public let CentrifugeErrorDomain = "com.Centrifuge.error.domain"
public let CentrifugeWebSocketErrorDomain = "com.Centrifuge.error.domain.websocket"
public let CentrifugeErrorMessageKey = "com.Centrifuge.error.messagekey"

public enum CentrifugeErrorCode: Int {
    case CentrifugeMessageWithError
}

public typealias CentrifugeMessageHandler = (CentrifugeServerMessage?, Error?) -> Void

public class Centrifuge {
    public class func client(url: String, creds: CentrifugeCredentials, delegate: CentrifugeClientDelegate) -> CentrifugeClient {
        let client = CentrifugeClientImpl()
        client.builder = CentrifugeClientMessageBuilderImpl()
        client.parser = CentrifugeServerMessageParserImpl()
        client.creds = creds
        client.url = url
        client.delegate = delegate
        
        return client
    }
    
    public class func createToken(string: String, key: String) -> String {
        let hmacs5 = HMAC(algorithm:.sha256, key:key).update(string: string)?.final()
        let token = hexString(fromArray: hmacs5!)
        return token
    }
}
