//
//  NotifyPropsMappingContainer.swift
//  Mattermost
//
//  Created by TaHyKu on 27.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import RestKit

private protocol NotifyPropsMappingsContainerResponseMappings: class {
    static func mapping() -> RKObjectMapping
}

final class NotifyPropsMappingsContainer: BaseMappingsContainer {
    override class var classForMapping: AnyClass! {
        return NotifyProps.self
    }
}


//MARK: NotifyPropsMappingsContainerResponseMappings

extension NotifyPropsMappingsContainer: NotifyPropsMappingsContainerResponseMappings {
    override class func mapping() -> RKObjectMapping {
        let mapping = super.mapping()
        mapping.addAttributeMappings(from: [
            "firstName"         : NotifyPropsAttributes.channel.rawValue,
            "comments"          : NotifyPropsAttributes.comments.rawValue,
            "desktop"           : NotifyPropsAttributes.desktop.rawValue,
            "desktop_duration"  : NotifyPropsAttributes.desktop_duration.rawValue,
            "desktop_sound"     : NotifyPropsAttributes.desktop_sound.rawValue,
            "email"             : NotifyPropsAttributes.email.rawValue,
            "first_name"        : NotifyPropsAttributes.first_name.rawValue,
            "mention_keys"      : NotifyPropsAttributes.mention_keys.rawValue,
            "push"              : NotifyPropsAttributes.push.rawValue,
            "push_status"       : NotifyPropsAttributes.push_status.rawValue
            ])
        return mapping
    }
}
