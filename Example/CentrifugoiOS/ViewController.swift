//
//  ViewController.swift
//  CentrifugoiOS
//
//  Created by Herman Saprykin on 04/18/2016.
//  Copyright (c) 2016 Herman Saprykin. All rights reserved.
//

import UIKit

import CentrifugoiOS

typealias MessagesCallback = CentrifugoServerMessage -> Void

class ViewController: UIViewController, CentrifugoChannelDelegate {
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
        
        connect()
    }
    
    //MARK:- Interactions with server
    var client: CentrifugoClient!
    var callbacks = [String : MessagesCallback]()
    
    let channel = "jsfiddle-chat"
    let user = "ios-swift"
    let secret = "secret"
    
//  eachMessage(handleError(present(handleCallback)))(messages)
    
    func connect() {
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        
        let creds = CentrifugoCredentials(secret: secret, user: user, timestamp: timestamp)
        let url = "wss://centrifugo.herokuapp.com/connection/websocket"
        client = Centrifugal.client(url, creds: creds)
        client.connect { (error) in
            print("connect error: \(error)")
            
            self.client.subscribe("jsfiddle-chat", delegate: self, completion: { (message, error) in
                print("subscribe error: \(error)")
                print("subscribe message: \(message)")
            })
        }
    }
    
    func client(client: CentrifugoClient, didReceiveInChannel channel: String, message: CentrifugoServerMessage) {
        print("channel: \(channel)")
        print("message: \(message)")
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
        }
    }
}


