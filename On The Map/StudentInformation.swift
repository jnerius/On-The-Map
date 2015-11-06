//
//  StudentInformation.swift
//  On The Map
//
//  Created by Josh on 11/1/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

struct StudentInformation {
    var firstName: String = ""
    var lastName:  String = ""
    var latitude:  Double = 0.0
    var longitude: Double = 0.0
    var mapString: String = ""
    var mediaURL:  String = ""
    var objectId:  String = ""
    var uniqueKey: String = ""
    var createdAt: NSDate = NSDate()
    var updatedAt: NSDate = NSDate()
    
    init(dictionary: [String:AnyObject]) {
        if let jFirstName = dictionary["firstName"] as? String { firstName = jFirstName }
        if let jLastName  = dictionary["lastName"]  as? String { lastName  = jLastName }
        if let jLatitude  = dictionary["latitude"]  as? Double { latitude  = jLatitude }
        if let jLongitude = dictionary["longitude"] as? Double { longitude = jLongitude }
        if let jMediaURL  = dictionary["mediaURL"]  as? String { mediaURL  = jMediaURL }
        if let jObjectId  = dictionary["objectId"]  as? String { objectId  = jObjectId }
        if let jUniqueKey = dictionary["uniqueKey"] as? String { uniqueKey = jUniqueKey }
        if let jCreatedAt = dictionary["createdAt"] as? NSDate { createdAt = jCreatedAt }
        if let jUpdatedAt = dictionary["updatedAt"] as? NSDate { updatedAt = jUpdatedAt }
    }
    
    static func userLocationsFromResults(results: [[String:AnyObject]]) -> [StudentInformation] {
        var userLocations = [StudentInformation]()
        
        for result in results {
            userLocations.append(StudentInformation(dictionary: result))
        }
        
        return userLocations
    }
}