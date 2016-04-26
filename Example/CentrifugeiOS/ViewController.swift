//
//  ViewController.swift
//  CentrifugeiOS
//
//  Created by Herman Saprykin on 04/18/2016.
//  Copyright (c) 2016 Herman Saprykin. All rights reserved.
//

import UIKit

import CentrifugeiOS

typealias MessagesCallback = CentrifugeServerMessage -> Void

class ViewController: UIViewController, CentrifugeChannelDelegate, CentrifugeClientDelegate {
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
        
        let timestamp = "\(Int(NSDate().timeIntervalSince1970))"
        
        let creds = CentrifugeCredentials(secret: secret, user: user, timestamp: timestamp)
        let url = "wss://centrifugo.herokuapp.com/connection/websocket"
        client = Centrifuge.client(url, creds: creds, delegate: self)
    }
    
    //MARK:- Interactions with server
    var client: CentrifugeClient!
    
    let channel = "jsfiddle-chat"
    let user = "ios-swift"
    let secret = "secret"

    func publish(text: String) {
        client.publish(channel, data:  ["nick" : nickName, "input" : text]) { message, error in
            print("publish message: \(message)")
        }
    }
    
    //MARK: CentrifugeClientDelegate
    func client(client: CentrifugeClient, didReceiveError error: NSError) {
        showError(error)
    }
    
    func client(client: CentrifugeClient, didDisconnect message: CentrifugeServerMessage) {
        print("didDisconnect message: \(message)")
        datasource.removeAll()
        tableView.reloadData()
    }
    
    func client(client: CentrifugeClient, didReceiveRefresh message: CentrifugeServerMessage) {
        print("didReceiveRefresh message: \(message)")
    }
    
    //MARK: CentrifugeChannelDelegate
    func client(client: CentrifugeClient, didReceiveMessageInChannel channel: String, message: CentrifugeServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], input = data["input"] as? String, nick = data["nick"] as? String {
            addItem(nick, subtitle: input)
        }
    }
    
    func client(client: CentrifugeClient, didReceiveJoinInChannel channel: String, message: CentrifugeServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
            addItem(message.method.rawValue, subtitle: user)
        }
    }
    
    func client(client: CentrifugeClient, didReceiveLeaveInChannel channel: String, message: CentrifugeServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], user = data["user"] as? String {
            addItem(message.method.rawValue, subtitle: user)
        }
    }
    
    func client(client: CentrifugeClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugeServerMessage) {
        print("didReceiveUnsubscribeInChannel \(message)"   )
    }
    
    //MARK: Presentation
    func addItem(title: String, subtitle: String) {
        self.datasource.addItem(TableViewItem(title: title, subtitle: subtitle))
        self.tableView.reloadData()
    }
    
    
    func showAlert(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let close = UIAlertAction(title: "Close", style: .Cancel) { _ in
            vc.dismissViewControllerAnimated(true, completion: nil)
        }
        vc.addAction(close)
        
        showViewController(vc, sender: self)
    }
    
    func showError(error: Any) {
        showAlert("Error", message: "\(error)")
    }
    
    func showMessage(message: CentrifugeServerMessage) {
        showAlert("Message", message: "\(message)")
    }
    
    func showResponse(message: CentrifugeServerMessage?, error: NSError?) {
        if let msg = message {
            showMessage(msg)
        } else if let err = error {
            showError(err)
        }
    }
    
    //MARK:- Interactions with user
    
    @IBAction func sendButtonDidPress(sender: AnyObject) {
        if let text = messageTextField.text where text.characters.count > 0 {
            messageTextField.text = ""
            publish(text)
        }
    }
    
    @IBAction func actionButtonDidPress() {
        let alert = UIAlertController(title: "Choose command", message: nil, preferredStyle: .ActionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { _ in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(cancel)
        
        let connect = UIAlertAction(title: "Connect", style: .Default) { _ in
            self.client.connect(self.showResponse)
        }
        alert.addAction(connect)
        
        let disconnect = UIAlertAction(title: "Disconnect", style: .Default) { _ in
            self.client.disconnect()
        }
        alert.addAction(disconnect)
        
        let ping = UIAlertAction(title: "Ping", style: .Default) { _ in
            self.client.ping(self.showResponse)
        }
        alert.addAction(ping)
        
        let subscribe = UIAlertAction(title: "Subscribe to \(channel)", style: .Default) { _ in
            self.client.subscribe(self.channel, delegate: self, completion: self.showResponse)
        }
        alert.addAction(subscribe)
        
        let unsubscribe = UIAlertAction(title: "Unsubscribe from \(channel)", style: .Default) { _ in
            self.client.unsubscribe(self.channel, completion: self.showResponse)
        }
        alert.addAction(unsubscribe)
        
        let history = UIAlertAction(title: "History \(channel)", style: .Default) { _ in
            self.client.history(self.channel, completion: self.showResponse)
        }
        alert.addAction(history)
        
        let presence = UIAlertAction(title: "Presence \(channel)", style: .Default) { _ in
            self.client.presence(self.channel, completion:self.showResponse)
        }
        alert.addAction(presence)
        
        presentViewController(alert, animated: true, completion: nil)
    }
}


