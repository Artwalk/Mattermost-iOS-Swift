//
//  RKResponseDescriptor+RuntimeFinder.swift
//  Mattermost
//
//  Created by Maxim Gubin on 01/07/16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

extension RKResponseDescriptor {
    class func findAllDescriptors() -> Array<RKResponseDescriptor>{
        return dumpValuesFromRootClass(RealmObject.self, withClassPrefix: Constants.Common.RestKitPrefix) as! Array
    }
}
