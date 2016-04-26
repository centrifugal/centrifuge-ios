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

class ViewController: UIViewController, CentrifugoChannelDelegate, CentrifugoClientDelegate {
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
    
    let channel = "jsfiddle-chat"
    let user = "ios-swift"
    let secret = "secret"
    
    func connect() {
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        
        let creds = CentrifugoCredentials(secret: secret, user: user, timestamp: timestamp)
        let url = "wss://centrifugo.herokuapp.com/connection/websocket"
        client = Centrifugal.client(url, creds: creds, delegate: self)
        client.connect { (error) in
            print("connect error: \(error)")
            
            self.client.subscribe("jsfiddle-chat", delegate: self, completion: { (message, error) in
                print("subscribe error: \(error)")
                print("subscribe message: \(message)")
            })
        }
    }
    
    //MARK: CentrifugoClientDelegate
    func client(client: CentrifugoClient, didReceiveError error: NSError) {
        print("\(error)")
    }
    
    func client(client: CentrifugoClient, didDisconnect: Any) {
        print("disconnect")
    }
    
    func client(client: CentrifugoClient, didReceiveRefresh: Any) {
        print("refresh")
    }
    
    //MARK: CentrifugoChannelDelegate
    func client(client: CentrifugoClient, didReceiveMessageInChannel channel: String, message: CentrifugoServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], input = data["input"] as? String, nick = data["nick"] as? String {
            addItem(nick, subtitle: input)
        }
    }
    
    func client(client: CentrifugoClient, didReceiveJoinInChannel channel: String, message: CentrifugoServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
            addItem(message.method.rawValue, subtitle: user)
        }
    }
    
    func client(client: CentrifugoClient, didReceiveLeaveInChannel channel: String, message: CentrifugoServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
            addItem(message.method.rawValue, subtitle: user)
        }
    }
    
    func client(client: CentrifugoClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugoServerMessage) {
        print(message)
    }
    
    //MARK: Presentation
    func addItem(title: String, subtitle: String) {
        self.datasource.addItem(TableViewItem(title: title, subtitle: subtitle))
        self.tableView.reloadData()
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


