//
//  ParseClient.swift
//  On The Map
//
//  Created by Josh on 11/4/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

struct ParseConstants {
    static let BaseURL               = "https://api.parse.com/1/classes/"
    static let ParseApplicationId    = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let ParseRestApiKey       = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let MethodStudentLocation = "StudentLocation"
}

class ParseClient : NSObject {
    let restClient = RESTClient()
    
    func getStudentLocations(limit: Int?, skip: Int?, order: String?, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        let headers = [
            "X-Parse-Application-Id": ParseConstants.ParseApplicationId,
            "X-Parse-REST-API-Key":   ParseConstants.ParseRestApiKey
        ]
        
        restClient.doGET(ParseConstants.BaseURL, method: ParseConstants.MethodStudentLocation, parameters: nil, headers: headers) { (result, error) -> Void in
            if let results = result["results"] as? [[String:AnyObject]] {
                let userLocations = StudentInformation.userLocationsFromResults(results)
                let sortedUserLocations = userLocations.sort {
                    $0.updatedAt.compare($1.updatedAt) == .OrderedDescending
                }
                
                completionHandler(result: sortedUserLocations, error: nil)
            }
        }
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}