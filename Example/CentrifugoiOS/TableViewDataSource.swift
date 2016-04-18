//
//  TableViewDataSource.swift
//  CentrifugoiOS
//
//  Created by Herman Saprykin on 18/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

struct TableViewItem {
    let title: String
    let subtitle: String
}

extension UITableViewCell {
    func configureWithItem(item : TableViewItem) {
        self.textLabel?.text = item.title
        self.detailTextLabel?.text = item.subtitle
    }
}

class TableViewDataSource : NSObject, UITableViewDataSource {
    private var items = [TableViewItem]()
    
    func addItem(item: TableViewItem) {
        items.append(item)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LeftDetail", forIndexPath: indexPath)
        cell.configureWithItem(items[indexPath.row])
        return cell
    }
}