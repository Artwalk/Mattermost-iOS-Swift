//
//  ProfileTableViewCell.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit

protocol ProfileTableViewCellConfiguration {
    func configureWith(title: String, info: String?, icon: String)
    func configureWithObject(_ object: AnyObject)
}

class ProfileTableViewCell: UITableViewCell, Reusable {

//MARK: Properties
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var arrowButton: UIButton?
    @IBOutlet weak var infoLabelTrailingLayoutConstraint: NSLayoutConstraint?
    
    var isCopyEnabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


extension ProfileTableViewCell: ProfileTableViewCellConfiguration {
    func configureWith(title: String, info: String?, icon: String) {
        self.titleLabel?.text = title
        self.iconImageView?.image = UIImage(named: icon)
        self.infoLabel?.text = info
    }
    
    func configureWithObject(_ object: AnyObject) {
        if (object is ProfileDataSource) {
            let dataSource: ProfileDataSource = object as! ProfileDataSource
            self.titleLabel?.text = dataSource.title
            self.iconImageView?.image = UIImage.init(named: dataSource.iconName)
            self.infoLabel?.text = dataSource.info
        }
    }
}

private protocol ProfileTableViewCellSetup {
    func initialSetup()
}

fileprivate protocol Action: class {
    func longPressAction(recognizer:UILongPressGestureRecognizer)
}


//MARK: - Setup

extension ProfileTableViewCell: ProfileTableViewCellSetup {
    func initialSetup() {
        self.selectionStyle = .none
        self.titleLabel?.font = UIFont.kg_regular16Font()
        self.infoLabel?.font = UIFont.kg_regular16Font()
        self.titleLabel?.textColor = UIColor.kg_blackColor()
        self.infoLabel?.textColor = UIColor.kg_lightGrayColor()
        setupGestureRecognizers()
    }
    
    func setupGestureRecognizers() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(recognizer:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(longPress)
    }
}

//MARK: Action
extension ProfileTableViewCell: Action {
    func longPressAction(recognizer:UILongPressGestureRecognizer) {
        guard self.isCopyEnabled else { return }
        guard recognizer.state == .ended else { return }
        
        UIPasteboard.general.string = self.infoLabel?.text
        AlertManager.sharedManager.showSuccesWithMessage(message: "User information was copied to clipboard")
    }
}
