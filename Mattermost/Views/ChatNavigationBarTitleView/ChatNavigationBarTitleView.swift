//
//  ChatNavigationBarTitleView.swift
//  Mattermost
//
//  Created by Mariya on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class ChatNavigationBarTitleView: UIView {
    
    internal var statusIndicatorView : UIView?
    internal var titleLabel : UILabel?
    internal var disclosureView : UIView?
    
    var titleString : NSString?
    var channel : Channel?
    //var loadingView : UIActivityIndicatorView
    
    internal func configureWithChannel(channel: Channel, loadingInProgress:Bool) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
    }
    
    //Setup
    
    func setupBackgroundColor() {
        self.backgroundColor = ColorBucket.whiteColor
    }
    
    func setupStatusView() {
        let xPosition = CGFloat(8)
        let yPosition = CGFloat(CGRectGetHeight(self.bounds)/2 - 2)
        self.statusIndicatorView = UIView(frame: CGRectMake(xPosition, yPosition, 8, 8))
        self.addSubview(self.statusIndicatorView!)
        self.statusIndicatorView?.layer.cornerRadius = 4
    }
    
    func setupTitleLabel() {
        let xPosition = CGFloat(0)
        let yPosition = CGFloat(0)
        let titleWight = CGFloat(20)
        let titleHeight = CGFloat(20)
        self.titleLabel = UILabel(frame: CGRectMake(xPosition, yPosition, titleWight, titleHeight))
        self.addSubview(self.titleLabel!)
        self.titleLabel?.textColor = ColorBucket.blackColor
        self.titleLabel?.font = FontBucket.normalTitleFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
    
}