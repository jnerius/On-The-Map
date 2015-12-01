//
//  RESTClient.swift
//  On The Map
//
//  Created by Josh on 11/3/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import Foundation

class RESTClient : NSObject {
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Borrowing some aspects of code from method used for Movie Manager App
    func doPOST(urlString: String, method: String, parameters: [String : AnyObject]?, jsonBody: [String:AnyObject], headers: [String:String]?, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let url = NSURL(string: urlString + method)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        // Loop through headers and add them to request
        if let headers = headers {
            for header in headers {
                request.addValue(header.1, forHTTPHeaderField: header.0)
            }
        }
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                
                // Per submission 1 review, adding missing callback to completion handler
                completionHandler(result: nil, error: error)
                return
            }
            
            // Handle error codes
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                if let response = response as? NSHTTPURLResponse {
                    print("Your request (\(request.URL)) returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request (\(request.URL)) returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request (\(request.URL)) returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Error doing POST: '\(request)'"]
                completionHandler(result: nil, error: NSError(domain: "doPOST", code: 1, userInfo: userInfo))
                
                return
            }
            
            // Data returned?
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // If this is a Udacity URL, skip chars, otherwise do not skip any
            if urlString == UdacityConstants.BaseURL {
                self.parseJSONWithCompletionHandler(data, skipChars: 5, completionHandler: completionHandler)
            } else {
                self.parseJSONWithCompletionHandler(data, skipChars: 0, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
    }
    
    func doGET(urlString: String, method: String, parameters: [String : AnyObject]?, headers: [String : String]?, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {

        let url = NSURL(string: urlString + method)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for header in headers {
                request.addValue(header.1, forHTTPHeaderField: header.0)
            }
        }
        
        // Do the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Error in callback?
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                
                // Per submission 1 review, adding missing callback to completion handler
                completionHandler(result: nil, error: error)
                return
            }
            
            // Handle error codes if they exist
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request (\(request.URL)) returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request (\(request.URL)) returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request (\(request.URL)) returned an invalid response!")
                }
                
                let userInfo = [NSLocalizedDescriptionKey : "Error doing GET: '\(request)'"]
                completionHandler(result: nil, error: NSError(domain: "doGET", code: 1, userInfo: userInfo))

                return
            }
            
            // Data returned?
            guard let data = data else {
                completionHandler(result: response, error: NSError(domain: "doGET", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data"]))
                return
            }
            
            // Parse the result
            if urlString == UdacityConstants.BaseURL {
                self.parseJSONWithCompletionHandler(data, skipChars: 5, completionHandler: completionHandler)
            } else {
                self.parseJSONWithCompletionHandler(data, skipChars: 0, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func parseJSONWithCompletionHandler(data: NSData, skipChars: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let newData = data.subdataWithRange(NSMakeRange(skipChars, data.length - skipChars))
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(newData)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
}