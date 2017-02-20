//
//  ChannelInfoCellBuilder.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 15.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

final class ChannelInfoCellBuilder {
    
//MARK: Properties
    let tableView: UITableView?
    let channel: Channel?
    
//MARK: LifeCycle
    init(tableView:UITableView, channel:Channel) {
        self.tableView = tableView
        self.channel = channel
    }
    
}
