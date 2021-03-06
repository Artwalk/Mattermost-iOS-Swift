//
//  ProfileViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 30.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import UIKit
import QuartzCore
import WebImage
import MBProgressHUD
import Photos
import NVActivityIndicatorView

@objc private enum InfoSections : Int {
    case base
    case registration = 1
    
    static var count: Int { return InfoSections.registration.rawValue + 1}
}

protocol ProfileViewControllerConfiguration {
    func configureForCurrentUser(displayOnly: Bool)
    func configureFor(user: User)
}


class ProfileViewController: UIViewController {

//MARK: Properties
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var saveButton: UIBarButtonItem!
    
    fileprivate lazy var builder: ProfileCellBuilder = ProfileCellBuilder(tableView: self.tableView, displayOnly: self.isDisplayOnly!)
    var user: User?
    fileprivate var isDisplayOnly: Bool? = true
 
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        setupHeader()
        self.menuContainerViewController.panMode = .init(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.menuContainerViewController.panMode = .init(3)
        
        super.viewWillDisappear(animated)
    }
}


extension ProfileViewController: ProfileViewControllerConfiguration {
    func configureForCurrentUser(displayOnly: Bool) {
        self.user = DataManager.sharedInstance.currentUser!
        self.isDisplayOnly = displayOnly
        if !self.isDisplayOnly! { loadCurrentUser() }
    }
    
    func configureFor(user: User) {
//        print(user)
        self.user = user
    }
}


fileprivate protocol Setup {
    func initialSetup()
    func setupNavigationBar()
    func setupHeader()
    func setupTable()
}

fileprivate protocol Action {
    func backAction()
    func saveAction()
}

fileprivate protocol Navigation {
    func returnToChat()
    func proceedToUFSettingsWith(type: Int)
    func proccedToNSettings()
}

fileprivate protocol Request {
    func updateImage()
}


//MARK: Setup
extension ProfileViewController: Setup {
    func initialSetup() {
        setupNavigationBar()
        setupHeader()
        setupAvatarImageView()
        setupTable()
    }
    
    func setupNavigationBar() {
        self.title = "Profile"
        
        if !self.isDisplayOnly! {
            self.saveButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveAction))
            self.saveButton.isEnabled = false
            self.navigationItem.rightBarButtonItem = self.saveButton
        }
    }
    
    func setupHeader() {
        self.nicknameLabel?.font = UIFont.kg_semibold30Font()
        self.nicknameLabel?.textColor = UIColor.kg_blackColor()
        self.nicknameLabel?.text = self.user?.displayName
        
        self.fullnameLabel.font = UIFont.kg_semibold20Font()
        self.fullnameLabel.textColor = UIColor.kg_blackColor()
        self.fullnameLabel.adjustsFontSizeToFitWidth = true
        self.fullnameLabel.text = (self.user?.firstName)! + " " + (self.user?.lastName)!
    }
    
    func setupAvatarImageView() {
        self.avatarImageView?.layer.drawsAsynchronously = true
        self.avatarImageView?.backgroundColor = UIColor.red
        self.avatarImageView?.setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        
        self.avatarImageView.image = UIImage.sharedAvatarPlaceholder
        ImageDownloader.downloadFullAvatarForUser(self.user!) { [weak self] (image, error) in
            self?.avatarImageView.image = image
        }

        guard self.isDisplayOnly == false else { return }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePhoto))
        self.avatarImageView.addGestureRecognizer(tapGestureRecognizer);
        self.avatarImageView?.isUserInteractionEnabled = true
    }
    
    func setupTable() {
        self.tableView?.backgroundColor = UIColor.kg_lightLightGrayColor()
        self.tableView?.register(ProfileTableViewCell.nib, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier, cacheSize: 10)
        self.tableView.isScrollEnabled = !self.isDisplayOnly!
    }
}


//MARK: Action
extension ProfileViewController: Action {
    func backAction() {
        returnToChat()
    }
    
    func saveAction() {
        updateImage()
    }
}


//MARK: Navigation
extension ProfileViewController: Navigation {
    func returnToChat() {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    func proceedToUFSettingsWith(type: Int) {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let uFSettings = storyboard.instantiateViewController(withIdentifier: "UFSettingsTableViewController") as! UFSettingsTableViewController
        uFSettings.configureWith(userFieldType: type)
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(uFSettings, animated: true)
    }
    
    func proccedToNSettings() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let nSettings = storyboard.instantiateViewController(withIdentifier: "NSettingsTableViewController")
        let navigation = self.menuContainerViewController.centerViewController
        (navigation! as AnyObject).pushViewController(nSettings, animated: true)
    }
}

//MARK: Request
extension ProfileViewController: Request {
    func loadCurrentUser() {
        Api.sharedInstance.loadCurrentUser { (error) in
            guard error == nil else { self.handleErrorWith(message: (error?.message)!); return }
            
            self.user = DataManager.sharedInstance.currentUser
            self.tableView.reloadData()
        }
    }
    
    internal func updateImage() {
        guard Api.sharedInstance.isNetworkReachable() else { handleErrorWith(message: "No Internet connectivity detected"); return }
        self.showLoaderView(topOffset: 0.0, bottomOffset: 0.0)
        let image = self.avatarImageView.image
        self.saveButton.isEnabled = false
        Api.sharedInstance.update(profileImage: image!, completion: { (error) in
            guard error == nil else { self.saveButton.isEnabled = true; self.hideLoaderView(); return }
            SDImageCache.shared().removeImage(forKey: self.user?.smallAvatarCacheKey())
            SDImageCache.shared().removeImage(forKey: self.user?.avatarLink)
            
            ImageDownloader.downloadFeedAvatarForUser(self.user!) { (image, error) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationsNames.ReloadRightMenuNotification), object: nil)
            }
            ImageDownloader.downloadFullAvatarForUser(self.user!) { _,_ in }
            self.saveButton.isEnabled = false
            self.hideLoaderView()
        }, progress: { (progress) in
        })
    }
}

//MARK: UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.Profile.SectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.builder.numberOfRowsFor(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.builder.cellFor(user: self.user!, indexPath: indexPath)
    }
}


//MARK: UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !self.isDisplayOnly! else { return }
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                proceedToUFSettingsWith(type: Constants.UserFieldType.FullName)
            case 1:
                proceedToUFSettingsWith(type: Constants.UserFieldType.UserName)
            case 2:
                proceedToUFSettingsWith(type: Constants.UserFieldType.NickName)
            case 3:
                changeProfilePhoto()
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                proceedToUFSettingsWith(type: Constants.UserFieldType.Email)
            case 1:
                proceedToUFSettingsWith(type: Constants.UserFieldType.Password)
            case 2:
                proccedToNSettings()
            default:
                break
            }
        }
    }
}


//MARK: UIImagePickerController
extension ProfileViewController {
    func changeProfilePhoto() {
        guard self.user?.identifier == Preferences.sharedInstance.currentUserId else { return }
        
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let openCameraAction = UIAlertAction.init(title: "Take photo", style: .default) { (action) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                AlertManager.sharedManager.showWarningWithMessage(message: "Camera is not available on this device.")
                return
            }
            let cameraMediaType = AVMediaTypeVideo
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
            if cameraAuthorizationStatus == .notDetermined {
                AVCaptureDevice.requestAccess(forMediaType: cameraMediaType, completionHandler: { (granted) in
                    guard granted else { AlertManager.sharedManager.showWarningWithMessage(message: "Access denied. You can unlock camera in the system settings")
                        return
                    }
                    self.presentImagePickerControllerWithType(.camera)
                })
            }
            guard cameraAuthorizationStatus == .authorized else {
                if cameraAuthorizationStatus != .notDetermined {
                    AlertManager.sharedManager.showWarningWithMessage(message: "Access denied. You can unlock camera in the system settings")
                }
                return
            }
            
            self.presentImagePickerControllerWithType(.camera)
        }
        let openGalleryAction = UIAlertAction.init(title: "Take from library", style: .default) { (action) in
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.presentImagePickerControllerWithType(.photoLibrary)
                return
            }
            
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    DispatchQueue.main.sync {
                        self.presentImagePickerControllerWithType(.photoLibrary)
                    }
                case .denied:
                    DispatchQueue.main.sync {
                        AlertManager.sharedManager.showWarningWithMessage(message: "Application is not allowed to access Photo data.")
                        return
                    }
                default:
                    print("Default")
                }
            })
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(openCameraAction)
        alertController.addAction(openGalleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePickerControllerWithType(_ type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController.init()
        pickerController.sourceType = type
        pickerController.delegate = self
        
        self.present(pickerController, animated: true, completion: nil)
    }
}


//MARK: UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.avatarImageView.image = image.fixedOrientation()
        self.saveButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController {
    func showLoaderProfileView() {
        let screenSize = UIScreen.main.bounds
        
        let y = self.navigationController?.navigationBar.frame.height
        let loader = UIView.init(frame: CGRect(x: 0,
                                               y: 0 - y!,
                                               width: screenSize.width,
                                               height: screenSize.height))
        loader.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.92)
        
        let frame = CGRect(x: (screenSize.width-screenSize.width/7)/2, y: (screenSize.height-screenSize.height/7)/2, width: screenSize.width/7, height: screenSize.height/7)
        let color = UIColor.kg_blueColor()
        let spinner = NVActivityIndicatorView(frame: frame, type: .ballPulse, color: color, padding: 0.0)
        loader.addSubview(spinner)
        spinner.startAnimating()
        self.view.addSubview(loader)
    }
}
