//
//  Protocols.swift
//  Pods
//
//  Created by Herman Saprykin on 26/04/16.
//
//

public protocol CentrifugeClientDelegate {
    func client(client: CentrifugeClient, didReceiveError error:NSError)
    func client(client: CentrifugeClient, didReceiveRefresh: CentrifugeServerMessage)
    func client(client: CentrifugeClient, didDisconnect: CentrifugeServerMessage)
}

public protocol CentrifugeChannelDelegate {
    func client(client: CentrifugeClient, didReceiveMessageInChannel channel: String, message: CentrifugeServerMessage)
    func client(client: CentrifugeClient, didReceiveJoinInChannel channel: String, message: CentrifugeServerMessage)
    func client(client: CentrifugeClient, didReceiveLeaveInChannel channel: String, message: CentrifugeServerMessage)
    func client(client: CentrifugeClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugeServerMessage)
}

public protocol CentrifugeClient {
    //MARK: General methods
    func connect(completion: CentrifugeMessageHandler)
    func disconnect()
    func ping(completion: CentrifugeMessageHandler)

    //MARK: Channel related methods
    func subscribe(channel: String, delegate: CentrifugeChannelDelegate, completion: CentrifugeMessageHandler)
    func subscribe(channel: String, delegate: CentrifugeChannelDelegate, lastMessageUID: String, completion: CentrifugeMessageHandler)
    
    func publish(channel: String, data: [String : AnyObject], completion: CentrifugeMessageHandler)
    func unsubscribe(channel: String, completion: CentrifugeMessageHandler)
    func history(channel: String, completion: CentrifugeMessageHandler)
    func presence(channel: String, completion: CentrifugeMessageHandler)
}

protocol CentrifugeClientUnimplemented {
    
    var delegate: CentrifugeClientDelegate? {get set}
    var connected: Bool {get}
}
