//
//  ViewController.swift
//  CentrifugoiOS
//
//  Created by Herman Saprykin on 04/18/2016.
//  Copyright (c) 2016 Herman Saprykin. All rights reserved.
//

import UIKit

import SwiftWebSocket
import CentrifugoiOS

typealias MessagesCallback = CentrifugoServerMessage -> Void

class ViewController: UIViewController {
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let datasource = TableViewDataSource()
    
    var nickName: String {
        get {
            if let nick = self.nickTextField.text where nick.characters.count > 0 {
                return nick
            }else {
                return "anonymous"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = datasource
        open()
    }

    //MARK:- Interactions with server
    let ws = WebSocket()
    let builder = Centrifugal.messageBuilder()
    let parser = Centrifugal.messageParser()
    
    var callbacks = [String : MessagesCallback]()
    
    let channel = "jsfiddle-chat"
    let user = "ios-swift"
    let secret = "secret"
    let url = "wss://centrifugo.herokuapp.com/connection/websocket"
    
    func open() {
        ws.event.message = message
        ws.event.open = connect
        ws.event.error = showError
        
        ws.open(url)
    }
    
    func message(data: Any) {
        let messages = try! parser.parse(data)
        eachMessage(handleError(present(handleCallback)))(messages)
    }

    func connect() {
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        
        let cred = CentrifugoCredentials(secret: secret, user: user, timestamp: timestamp)
        let message = builder.buildConnectMessage(cred)
        
        callbacks[message.uid] = { _ in
            self.subscribe()
        }
        
        try! ws.send(message)
    }
    
    func publish(text: String) {
        let message = builder.buildPublishMessageTo(channel, data: ["nick" : nickName, "input" : text])
        try! ws.send(message)
    }
    
    func subscribe() {
        let message = builder.buildSubscribeMessageTo(channel)
        try! ws.send(message)
    }
    
    //MARK:- Server response handlers
    
    func eachMessage(handler: (MessagesCallback)) -> ([CentrifugoServerMessage] -> Void) {
        return { messages in
            for message in messages {
                handler(message)
            }
        }
    }
    
    func handleError(handler: (MessagesCallback)) -> (MessagesCallback) {
        return { message in
            if let error = message.error {
                self.showError(error)
            } else {
                handler(message)
            }
        }
    }
    
    func present(handler: (MessagesCallback)) -> (MessagesCallback) {
        let addItem: ((String,String) -> Void) = { title, subtitle in
            self.datasource.addItem(TableViewItem(title: title, subtitle: subtitle))
            self.tableView.reloadData()
        }
        
        return { message in
            switch message.method {
            case .Join, .Leave:
                if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
                    addItem(message.method.rawValue, user)
                }
            case .Message:
                if let data = message.body?["data"] as? [String : AnyObject], input = data["input"] as? String, nick = data["nick"] as? String {
                    addItem(nick, input)
                }
            default:
                print("")
            }
            
            handler(message)
        }
    }
    
    func handleCallback(message: CentrifugoServerMessage){
        if let uid = message.uid, handler = self.callbacks[uid] {
            handler(message)
            self.callbacks.removeValueForKey(uid)
        }
    }

    
    func showError(error: Any) {
        let vc = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
        showViewController(vc, sender: self)
    }
    
    //MARK:- Interactions with user
    
    @IBAction func sendButtonDidPress(sender: AnyObject) {
        if let text = messageTextField.text where text.characters.count > 0 {
            messageTextField.text = ""
            publish(text)
        }
    }
}


