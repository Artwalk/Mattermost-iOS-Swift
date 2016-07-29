//
//  PrivateChannelTableViewCell.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 28.07.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

class PrivateChannelTableViewCell: UITableViewCell, LeftMenuTableViewCellProtocol {
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configureContentView()
        self.configureTitleLabel()
        self.configureStatusView()
    }
    
    
    func configureContentView() -> Void {
        self.backgroundColor = ColorBucket.sideMenuBackgroundColor
        self.badgeLabel.hidden = true
    }
    
    func configureTitleLabel() -> Void {
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.textColor = ColorBucket.lightGrayColor
        self.titleLabel.backgroundColor = ColorBucket.sideMenuBackgroundColor
    }
    
    func configureStatusView() -> Void {
        self.statusView.layer.cornerRadius = 4
    }
}

extension PrivateChannelTableViewCell {
    func configureWithChannel(channel: Channel) -> Void {
        self.titleLabel.text = channel.displayName!
    }
}
