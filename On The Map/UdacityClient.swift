//
//  UdacityClient.swift
//  On The Map
//
//  Created by Josh on 11/2/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

struct UdacityConstants {
    static let BaseURL = "https://www.udacity.com/api/";
}

class UdacityClient : NSObject {
    let restClient = RESTClient()
    
    func authenticate(username: String, password: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let authBody = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        
        restClient.doPOST(UdacityConstants.BaseURL, method: "session", parameters: [String:AnyObject](), jsonBody: authBody, headers: nil) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    func getUserData(userId: String, completionHandler: (result: UdacityUser!, error: NSError?) -> Void) {
        restClient.doGET(UdacityConstants.BaseURL, method: "users/\(userId)", parameters: nil, headers: nil) { (result, error) -> Void in
            let user = UdacityUser(dictionary: result as! [String : AnyObject])
            completionHandler(result: user, error: nil)
        }
    }
}