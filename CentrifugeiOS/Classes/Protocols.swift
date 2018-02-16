//
//  Protocols.swift
//  Pods
//
//  Created by German Saprykin on 26/04/16.
//
//

public protocol CentrifugeClientDelegate: class {
    func client(_ client: CentrifugeClient, didReceiveRefreshMessage message: CentrifugeServerMessage)
    // Possible errors:
    // - CentrifugeErrorDomain with CentrifugeErrorCode
    // - Starscream errors
    // - System errors, e.g. Socket is not connected.
    func client(_ client: CentrifugeClient, didDisconnectWithError error: Error)
}

public protocol CentrifugeChannelDelegate {
    func client(_ client: CentrifugeClient, didReceiveMessageInChannel channel: String, message: CentrifugeServerMessage)
    func client(_ client: CentrifugeClient, didReceiveJoinInChannel channel: String, message: CentrifugeServerMessage)
    func client(_ client: CentrifugeClient, didReceiveLeaveInChannel channel: String, message: CentrifugeServerMessage)
    func client(_ client: CentrifugeClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugeServerMessage)
}

public protocol CentrifugeClient {
    //MARK: General methods
    func connect(withCompletion: @escaping CentrifugeMessageHandler)
    func disconnect()
    func ping(withCompletion: @escaping CentrifugeMessageHandler)

    //MARK: Channel related methods
    func subscribe(toChannel: String, delegate: CentrifugeChannelDelegate, completion: @escaping CentrifugeMessageHandler)
    func subscribe(toChannel: String, delegate: CentrifugeChannelDelegate, lastMessageUID: String, completion: @escaping CentrifugeMessageHandler)
    
    func publish(toChannel: String, data: [String : Any], completion: @escaping CentrifugeMessageHandler)
    func unsubscribe(fromChannel: String, completion: @escaping CentrifugeMessageHandler)
    func history(ofChannel: String, completion: @escaping CentrifugeMessageHandler)
    func presence(inChannel: String, completion: @escaping CentrifugeMessageHandler)
}

protocol CentrifugeClientUnimplemented {
    
    var delegate: CentrifugeClientDelegate? {get set}
    var connected: Bool {get}
}
