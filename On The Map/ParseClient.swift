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
    
    let headers = [
        "X-Parse-Application-Id": ParseConstants.ParseApplicationId,
        "X-Parse-REST-API-Key":   ParseConstants.ParseRestApiKey
    ]
    
    func getStudentLocations(limit: Int?, skip: Int?, order: String?, completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        restClient.doGET(ParseConstants.BaseURL, method: ParseConstants.MethodStudentLocation, parameters: nil, headers: headers) { (result, error) -> Void in
            if let result = result {
                if let results = result["results"] as? [[String:AnyObject]] {
                    let userLocations = StudentInformation.userLocationsFromResults(results)
                    let sortedUserLocations = userLocations.sort {
                        return $0.updatedAt.compare($1.updatedAt) == .OrderedDescending
                    }
                    
                    completionHandler(result: sortedUserLocations, error: nil)
                } else {
                    print("in getStudentLocations, didn't go so well")
                    completionHandler(result: nil, error: error)
                }
            } else {
                completionHandler(result: nil, error: error)
            }
        }
    }
    
    func createStudentLocation(student: StudentInformation, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        print("createStudentLocation student -> \(student)")
        let body: [String:AnyObject] = [
            "uniqueKey": student.uniqueKey,
            "firstName": student.firstName,
            "lastName":  student.lastName,
            "latitude":  student.latitude,
            "longitude": student.longitude,
            "mapString": student.mapString,
            "mediaURL":  student.mediaURL
        ]
        
        restClient.doPOST(ParseConstants.BaseURL, method: ParseConstants.MethodStudentLocation, parameters: [String:AnyObject](), jsonBody: body, headers: headers) { (result, error) -> Void in
            
            print("In doPOST in createStudentLocation \(result)")
            
            completionHandler(result: result, error: error)
        }
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}