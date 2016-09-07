
//
//  User.swift
//  Mattermost
//
//  Created by Maxim Gubin on 20/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RealmSwift

private protocol Interface {
    func isSystem() -> Bool
}

final class User: RealmObject {
    dynamic var email: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var identifier: String! {
        didSet { computeAvatarUrl() }
    }
    dynamic var nickname: String?
    dynamic var displayNameWidth: Float = 0.0
    dynamic var avatarLink: String!
    dynamic var displayName: String? {
        didSet { computeDisplayNameWidth() }
    }
    dynamic var username: String? {
        didSet { computeNicknameIfRequired() }
    }
    override static func indexedProperties() -> [String] {
        return [UserAttributes.identifier.rawValue]
    }
    override static func primaryKey() -> String? {
        return UserAttributes.identifier.rawValue
    }
    
    func avatarURL() -> NSURL {
        return NSURL(string: self.avatarLink)!
    }
    func smallAvatarCacheKey() -> String {
        return self.avatarLink.stringByAppendingString("_small")
    }
}

enum UserAttributes: String {
    case privateStatus = "privateStatus"
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case identifier = "identifier"
    case nickname = "nickname"
    case status = "status"
    case username = "username"
    case avatarLink = "avatarLink"
}

//private protocol Mappings: class {
//    static func mapping() -> RKObjectMapping
//    static func directProfileMapping() -> RKObjectMapping
//}

private protocol Computatations: class {
    func computeDisplayNameWidth()
    func computeDisplayName()
    func computeAvatarUrl()
    func computeNicknameIfRequired()
}


// MARK: - Mappings
//extension User: Mappings {
//    override class func mapping() -> RKObjectMapping {
//        let mapping = super.mapping()
//        mapping.addAttributeMappingsFromDictionary([
//            "first_name" : UserAttributes.firstName.rawValue,
//            "last_name"  : UserAttributes.lastName.rawValue,
//            "username"   : UserAttributes.username.rawValue,
//            "nickname"   : UserAttributes.nickname.rawValue
//        ])
//        return mapping
//    }
//    static func directProfileMapping() -> RKObjectMapping {
//        let mapping = super.emptyMapping()
//        mapping.forceCollectionMapping = true
//        mapping.addAttributeMappingFromKeyOfRepresentationToAttribute(UserAttributes.identifier.rawValue)
//        mapping.addAttributeMappingsFromDictionary([
//            "(\(UserAttributes.identifier)).first_name" : UserAttributes.firstName.rawValue,
//            "(\(UserAttributes.identifier)).last_name" : UserAttributes.lastName.rawValue,
//            "(\(UserAttributes.identifier)).username" : UserAttributes.username.rawValue,
//            "(\(UserAttributes.identifier)).nickname" : UserAttributes.nickname.rawValue,
//            "(\(UserAttributes.identifier)).email" : UserAttributes.email.rawValue
//        ])
//        return mapping
//    }
//    
//}


extension User: Computatations {
    func computeNicknameIfRequired() {
        guard self.nickname == nil else { return }
        self.nickname = self.username
    }
    func computeDisplayNameWidth() {
        self.displayNameWidth = StringUtils.widthOfString(self.displayName, font: FontBucket.postAuthorNameFont)
    }
    
    func computeAvatarUrl() {
        self.avatarLink = Api.sharedInstance.avatarLinkForUser(self)
    }
    
    func computeDisplayName() {
        self.displayName = self.username
    }
}

extension User: Interface {
    func isSystem() -> Bool {
        return self.identifier == Constants.Realm.SystemUserIdentifier
    }
}