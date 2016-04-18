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

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let ws = WebSocket()
    let builder = Centrifugal.messageBuilder()
    
    let url = "wss://centrifugo.herokuapp.com/connection/websocket"
    var items = [(title: String, subtitle: String)]()
    
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
        
        ws.event.open = {
            self.connect()
        }
        
        ws.event.message = Centrifugal.messageParseHandler(errorHandlerDecorator(viewHandlerDecorator(concreteMessageHandler)))
        
        ws.event.error = { error in
            print(error)
        }
        
        ws.open(url)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LeftDetail", forIndexPath: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].title
        cell.detailTextLabel?.text = items[indexPath.row].subtitle
        
        return cell
    }
    
    @IBAction func sendButtonDidPress(sender: AnyObject) {
        if let text = messageTextField.text {
            messageTextField.text = nil
            publish(text)
        }
    }
    
    func connect() {
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        
        let cred = CentrifugoCredentials(secret: "secret", user: "ios-swift", timestamp: timestamp)
        let message = builder.buildConnectMessage(cred)
        
        callbacks[message.uid] = { message in
            self.subscribe()
        }
        
        try! ws.send(message)
    }
    
    func publish(text: String) {
        let message = builder.buildPublishMessageTo("jsfiddle-chat", data: ["nick" : nickName, "input" : text])
        callbacks[message.uid] = { message in
        }
        try! ws.send(message)
    }
    
    func subscribe() {
        let message = builder.buildSubscribeMessageTo("jsfiddle-chat")
        
        try! ws.send(message)
    }
    
    func concreteMessageHandler(messages: [CentrifugoServerMessage]) {
        for message in messages {
            print("Handle message \(message)")
            
            if let uid = message.uid, handler = self.callbacks[uid] {
                handler(message)
                self.callbacks.removeValueForKey(uid)
            }
        }
        
    }
    
    func errorHandlerDecorator(handler: ([CentrifugoServerMessage] -> Void)) -> ([CentrifugoServerMessage] -> Void) {
        return { messages in
            if let error = messages[0].error {
                self.showError(error)
            } else {
                handler(messages)
            }
        }
    }
    
    func viewHandlerDecorator(handler: ([CentrifugoServerMessage] -> Void)) -> ([CentrifugoServerMessage] -> Void) {
        return { messages in
            for message in messages {
                switch message.method {
                case .Join, .Leave:
                    if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
                        self.items.append((title: message.method.rawValue, subtitle: user))
                        self.tableView.reloadData()
                    }
                case .Message:
                    if let data = message.body?["data"] as? [String : AnyObject], input = data["input"] as? String, nick = data["nick"] as? String {
                        self.items.append((title: nick, subtitle: input))
                        self.tableView.reloadData()
                    }
                default:
                    print("")
                }
            }
            
            handler(messages)
        }
    }
    
    func showError(error: String) {
        let vc = UIAlertController(title: "Error", message: error, preferredStyle: .Alert)
        showViewController(vc, sender: self)
    }
}


