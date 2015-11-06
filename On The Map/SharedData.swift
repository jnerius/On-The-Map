//
//  SharedData.swift
//  On The Map
//
//  Created by Josh on 11/4/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

class SharedData {
    static var studentLocations = [StudentInformation]()
    
    static func studentLocations(refresh: Bool) -> [StudentInformation] {
        if (studentLocations.count == 0 || refresh) {
            print("SharedData.studentLocations: refreshing data...")
            ParseClient.sharedInstance().getStudentLocations(nil, skip: nil, order: nil) { (studentLocations, error) -> Void in
                if let locations = studentLocations {
                    self.studentLocations = locations
                }
            }
        } else {
            print("SharedData.studentLocations: using cached data...")
        }
        
        return self.studentLocations
    }
}