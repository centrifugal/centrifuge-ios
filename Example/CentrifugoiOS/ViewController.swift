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
    
    let ws = WebSocket()
    let builder = Centrifugal.messageBuilder()
    let datasource = TableViewDataSource()
    var callbacks = [String : MessagesCallback]()
    
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
        ws.event.message = Centrifugal.messagesParser(eachMessage(handleError(present(handleCallback))))
        ws.event.open = connect
        ws.event.error = showError
        
        ws.open("wss://centrifugo.herokuapp.com/connection/websocket")
    }
    
    @IBAction func sendButtonDidPress(sender: AnyObject) {
        if let text = messageTextField.text where text.characters.count > 0 {
            messageTextField.text = ""
            publish(text)
        }
    }
    
    func connect() {
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        
        let cred = CentrifugoCredentials(secret: "secret", user: "ios-swift", timestamp: timestamp)
        let message = builder.buildConnectMessage(cred)
        
        callbacks[message.uid] = { _ in
            self.subscribe()
        }
        
        try! ws.send(message)
    }
    
    func publish(text: String) {
        let message = builder.buildPublishMessageTo("jsfiddle-chat", data: ["nick" : nickName, "input" : text])
        try! ws.send(message)
    }
    
    func subscribe() {
        let message = builder.buildSubscribeMessageTo("jsfiddle-chat")
        try! ws.send(message)
    }
    
    func handleCallback(message: CentrifugoServerMessage) {
        if let uid = message.uid, handler = self.callbacks[uid] {
            handler(message)
            self.callbacks.removeValueForKey(uid)
        }
    }
    
    func handleError(handler: (CentrifugoServerMessage -> Void)) -> (CentrifugoServerMessage -> Void) {
        return { message in
            if let error = message.error {
                self.showError(error)
            } else {
                handler(message)
            }
        }
    }
    
    func eachMessage(handler: (CentrifugoServerMessage -> Void)) -> ([CentrifugoServerMessage] -> Void) {
        return { messages in
            for message in messages {
                handler(message)
            }
        }
    }
    
    func present(handler: (CentrifugoServerMessage -> Void)) -> (CentrifugoServerMessage -> Void) {
        func addItem(title: String, subtitle: String) {
            datasource.addItem(TableViewItem(title: title, subtitle: subtitle))
            tableView.reloadData()
        }
        
        return { message in
            switch message.method {
            case .Join, .Leave:
                if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
                    addItem(message.method.rawValue, subtitle: user)
                }
            case .Message:
                if let data = message.body?["data"] as? [String : AnyObject], input = data["input"] as? String, nick = data["nick"] as? String {
                    addItem(nick, subtitle: input)
                }
            default:
                print("")
            }
            
            handler(message)
        }
    }
    
    func showError(error: Any) {
        let vc = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
        showViewController(vc, sender: self)
    }
}


