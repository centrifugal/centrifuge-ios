//
//  ViewController.swift
//  CentrifugeiOS
//
//  Created by German Saprykin on 04/18/2016.
//  Copyright (c) 2016 German Saprykin. All rights reserved.
//

import UIKit

import CentrifugeiOS

typealias MessagesCallback = (CentrifugeServerMessage) -> Void

class ViewController: UIViewController, CentrifugeChannelDelegate, CentrifugeClientDelegate {
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let datasource = TableViewDataSource()
    
    var nickName: String {
        get {
            if let nick = self.nickTextField.text, nick.count > 0 {
                return nick
            }else {
                return "anonymous"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = datasource
        
        let timestamp = "\(Int(Date().timeIntervalSince1970))"
        let token =  Centrifuge.createToken(string: "\(user)\(timestamp)", key: secret)
        
        let creds = CentrifugeCredentials(token: token, user: user, timestamp: timestamp)
        let url = "wss://centrifugo.herokuapp.com/connection/websocket"
        client = Centrifuge.client(url: url, creds: creds, delegate: self)
    }
    
    //MARK:- Interactions with server
    var client: CentrifugeClient!
    
    let channel = "jsfiddle-chat"
    let user = "ios-swift"
    let secret = "secret"

    func publish(_ text: String) {
        client.publish(toChannel: channel, data:  ["nick" : nickName, "input" : text]) { message, error in
            print("publish message: \(String(describing: message))")
        }
    }
    
    //MARK: CentrifugeClientDelegate
    func client(_ client: CentrifugeClient, didReceiveError error: NSError) {
        showError(error)
    }
    
    func client(_ client: CentrifugeClient, didDisconnect message: CentrifugeServerMessage) {
        print("didDisconnect message: \(message)")
        datasource.removeAll()
        tableView.reloadData()
    }
    
    func client(_ client: CentrifugeClient, didReceiveRefresh message: CentrifugeServerMessage) {
        print("didReceiveRefresh message: \(message)")
    }
    
    //MARK: CentrifugeChannelDelegate
    func client(_ client: CentrifugeClient, didReceiveMessageInChannel channel: String, message: CentrifugeServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], let input = data["input"] as? String, let nick = data["nick"] as? String {
            addItem(nick, subtitle: input)
        }
    }
    
    func client(_ client: CentrifugeClient, didReceiveJoinInChannel channel: String, message: CentrifugeServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], let user = data["user"] as? String {
            addItem(message.method.rawValue, subtitle: user)
        }
    }
    
    func client(_ client: CentrifugeClient, didReceiveLeaveInChannel channel: String, message: CentrifugeServerMessage) {
        if let data = message.body?["data"] as? [String : AnyObject], let user = data["user"] as? String {
            addItem(message.method.rawValue, subtitle: user)
        }
    }
    
    func client(_ client: CentrifugeClient, didReceiveUnsubscribeInChannel channel: String, message: CentrifugeServerMessage) {
        print("didReceiveUnsubscribeInChannel \(message)"   )
    }
    
    //MARK: Presentation
    func addItem(_ title: String, subtitle: String) {
        self.datasource.addItem(TableViewItem(title: title, subtitle: subtitle))
        self.tableView.reloadData()
    }
    
    
    func showAlert(_ title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let close = UIAlertAction(title: "Close", style: .cancel) { _ in
            vc.dismiss(animated: true, completion: nil)
        }
        vc.addAction(close)
        
        show(vc, sender: self)
    }
    
    func showError(_ error: Any) {
        showAlert("Error", message: "\(error)")
    }
    
    func showMessage(_ message: CentrifugeServerMessage) {
        showAlert("Message", message: "\(message)")
    }
    
    func showResponse(_ message: CentrifugeServerMessage?, error: NSError?) {
        if let msg = message {
            showMessage(msg)
        } else if let err = error {
            showError(err)
        }
    }
    
    //MARK:- Interactions with user
    
    @IBAction func sendButtonDidPress(_ sender: AnyObject) {
        if let text = messageTextField.text, text.count > 0 {
            messageTextField.text = ""
            publish(text)
        }
    }
    
    @IBAction func actionButtonDidPress() {
        let alert = UIAlertController(title: "Choose command", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        
        let connect = UIAlertAction(title: "Connect", style: .default) { _ in
            self.client.connect(withCompletion: self.showResponse)
        }
        alert.addAction(connect)
        
        let disconnect = UIAlertAction(title: "Disconnect", style: .default) { _ in
            self.client.disconnect()
        }
        alert.addAction(disconnect)
        
        let ping = UIAlertAction(title: "Ping", style: .default) { _ in
            self.client.ping(withCompletion: self.showResponse)
        }
        alert.addAction(ping)
        
        let subscribe = UIAlertAction(title: "Subscribe to \(channel)", style: .default) { _ in
            self.client.subscribe(toChannel: self.channel, delegate: self, completion: self.showResponse)
        }
        alert.addAction(subscribe)
        
        let unsubscribe = UIAlertAction(title: "Unsubscribe from \(channel)", style: .default) { _ in
            self.client.unsubscribe(fromChannel: self.channel, completion: self.showResponse)
        }
        alert.addAction(unsubscribe)
        
        let history = UIAlertAction(title: "History \(channel)", style: .default) { _ in
            self.client.history(ofChannel: self.channel, completion: self.showResponse)
        }
        alert.addAction(history)
        
        let presence = UIAlertAction(title: "Presence \(channel)", style: .default) { _ in
            self.client.presence(inChannel: self.channel, completion:self.showResponse)
        }
        alert.addAction(presence)
        
        present(alert, animated: true, completion: nil)
    }
}


