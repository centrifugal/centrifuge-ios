//
//  Protocols.swift
//  Pods
//
//  Created by Herman Saprykin on 26/04/16.
//
//

public protocol CentrifugoClientDelegate {
    func client(client: CentrifugoClient, didReceiveError error:NSError)
    func client(client: CentrifugoClient, didReceiveRefresh: CentrifugoServerMessage)
    func client(client: CentrifugoClient, didDisconnect: CentrifugoServerMessage)
}

public protocol CentrifugoChannelDelegate {
    func client(client: CentrifugoClient, didReceiveMessageInChannel channel: String, message: CentrifugoServerMessage)
    func client(client: CentrifugoClient, didReceiveJoinInChannel channel: String, message: CentrifugoServerMessage)
    func client(client: CentrifugoClient, didReceiveLeaveInChannel channel: String, message: CentrifugoServerMessage)
    func client(client: CentrifugoClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugoServerMessage)
}

public protocol CentrifugoClient {
    //MARK: General methods
    func connect(completion: CentrifugoMessageHandler)
    func disconnect()
    func ping(completion: CentrifugoMessageHandler)

    //MARK: Channel related methods
    func subscribe(channel: String, delegate: CentrifugoChannelDelegate, completion: CentrifugoMessageHandler)
    func subscribe(channel: String, delegate: CentrifugoChannelDelegate, lastMessageUID: String, completion: CentrifugoMessageHandler)
    
    func publish(channel: String, data: [String : AnyObject], completion: CentrifugoMessageHandler)
    func unsubscribe(channel: String, completion: CentrifugoMessageHandler)
    func history(channel: String, completion: CentrifugoMessageHandler)
    func presence(channel: String, completion: CentrifugoMessageHandler)
}

protocol CentrifugoClientUnimplemented {
    
    var delegate: CentrifugoClientDelegate? {get set}
    var connected: Bool {get}
}
