//
//  UdacityUser.swift
//  On The Map
//
//  Created by Josh on 11/3/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

struct UdacityUser {
    var userId    = ""
    var firstName = ""
    var lastName  = ""
    
    init() {}
    
    init(dictionary: [String:AnyObject]) {
        if let userDict = dictionary["user"] as? [String:AnyObject] {
            if let key   = userDict["key"]        { userId    = key   as! String }
            if let first = userDict["first_name"] { firstName = first as! String }
            if let last  = userDict["last_name"]  { lastName  = last  as! String }
        }
    }
}