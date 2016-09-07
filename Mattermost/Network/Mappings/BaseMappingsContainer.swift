//
//  BaseMappingsContainer.swift
//  Mattermost
//
//  Created by Mariya on 06.09.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

protocol CommonMappings: class {
    static func mapping() -> RKObjectMapping
    static func emptyResponseMapping() -> RKObjectMapping
    static func emptyMapping() -> RKObjectMapping
    static func requestMapping() -> RKObjectMapping
}

class BaseMappingsContainer: RKObjectMapping {
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: RealmObject.self)
        mapping.addAttributeMappingsFromDictionary(["id" : CommonAttributes.identifier.rawValue])
        return mapping;
    }
    
    static func emptyResponseMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: NSNull.self)
    }
    
    static func emptyMapping() -> RKObjectMapping {
        return RKObjectMapping(withClass: RealmObject.self)
    }
    
   override class func requestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.requestMapping()
        mapping.addAttributeMappingsFromDictionary([CommonAttributes.identifier.rawValue : "id"])
        return mapping;
    }
}
