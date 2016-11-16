//
//  TableViewDataSource.swift
//  CentrifugeiOS
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
    func configureWithItem(_ item : TableViewItem) {
        self.textLabel?.text = item.title
        self.detailTextLabel?.text = item.subtitle
    }
}

class TableViewDataSource : NSObject, UITableViewDataSource {
    fileprivate var items = [TableViewItem]()
    
    func removeAll() {
        items.removeAll()
    }
    
    func addItem(_ item: TableViewItem) {
        items.append(item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftDetail", for: indexPath)
        cell.configureWithItem(items[indexPath.row])
        return cell
    }
}
