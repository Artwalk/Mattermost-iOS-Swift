//
//  ChannelDefaultTableViewCell.swift
//  Mattermost
//
//  Created by Julia Samoshchenko on 16.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
// >
final class ChannelDefaultTableViewCell: UITableViewCell, Reusable {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        setupAccessoryType()
        textLabel?.text = "Test"
    }
    func setupAccessoryType() {
        self.accessoryType = .DetailButton
    }
    
    func configureWithObject(object: ChannelInfoCellObject) {
        let data = object as! TitleWithImageData
        textLabel!.text = data.title
        imageView?.image = data.image
    }
}