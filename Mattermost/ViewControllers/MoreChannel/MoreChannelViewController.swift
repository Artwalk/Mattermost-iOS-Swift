//
//  MoreChannelViewController.swift
//  Mattermost
//
//  Created by Mariya on 23.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

class MoreChannelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let showChatViewController = "showChatViewController"
    private let privateTypeChannel = "D"
    private let publicTypeChannel = "O"
    private var results: Results<Channel>! = nil
    var realm: Realm?
    internal var isPrivateChannel : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        prepareResults()
        loadFitsPageOfData()
    }
    
//MARK: Setup
    
    func setupNavigationBar() {
        self.title = "More Channel".localized
    }
    
    func setupTableView () {
        self.tableView.backgroundColor = ColorBucket.whiteColor
        self.tableView.separatorColor = ColorBucket.rightMenuSeparatorColor
        self.tableView.registerNib(MoreChannelsTableViewCell.nib(), forCellReuseIdentifier: MoreChannelsTableViewCell.reuseIdentifier())
    }
    
}

//MARK: UITableViewDataSource

extension MoreChannelViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MoreChannelsTableViewCell.reuseIdentifier()) as! MoreChannelsTableViewCell
        let channel = self.results[indexPath.row] as Channel?
        cell.configureCellWithObject(channel!)
        return cell
    }
    
}

//MARK: UITableViewDelegate

extension MoreChannelViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(showChatViewController, sender: self.results[indexPath.row])
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MoreChannelsTableViewCell.height()
    }
    
    
//MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let selectedChannel = sender else { return }
        ChannelObserver.sharedObserver.selectedChannel = selectedChannel as? Channel
    }
}

//MARK: FetchedResultsController AND

extension MoreChannelViewController  {
    func prepareResults() {
        
        //Preferences.sharedInstance.currentUserId
        let typeValue = self.isPrivateChannel ? privateTypeChannel : publicTypeChannel
       // let userInTheChannel = Preferences.sharedInstance.currentUserId in ChannelRelationships.members.hashValue
        let predicate =  NSPredicate(format: "privateType == %@", typeValue)
        let sortName = ChannelAttributes.displayName.rawValue
        self.results = RealmUtils.realmForCurrentThread().objects(Channel.self).filter(predicate).sorted(sortName, ascending: true)
    }
    
    func loadFitsPageOfData(){
       Api.sharedInstance.loadAllChannelsWithCompletion { (error) in
            self.prepareResults()
            self.tableView.reloadData()
        }
    }
    
    
}
