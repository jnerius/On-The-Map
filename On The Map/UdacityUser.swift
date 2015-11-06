//
//  UdacityUser.swift
//  On The Map
//
//  Created by Josh on 11/3/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

struct UdacityUser {
    var userId = ""
    
    init(dictionary: [String:AnyObject]) {
        if let userDict = dictionary["user"] as? [String:AnyObject] {
            if let key = userDict["key"] {
                userId = key as! String
            }
        }
    }
}