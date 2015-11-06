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
    
    // Borrowing from method used for Movie Manager App.
    // Generic method to facilitate POST HTTP Requests.
    func doPOST(urlString: String, method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + method)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
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
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            print(data)
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            // FIXME
            if urlString == "https://www.udacity.com/api/" {
                self.parseJSONWithCompletionHandler(data, skipChars: 5, completionHandler: completionHandler)
            } else {
                self.parseJSONWithCompletionHandler(data, skipChars: 0, completionHandler: completionHandler)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    /*
    func doGET(urlString: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //return doGET(urlString, method: method, parameters: parameters, headers: nil, completionHandler: completionHandler);
        return doGET(urlString, method: method, parameters: parameters, headers: nil, completionHandler: { (result, error) -> Void in
            completionHandler(result: result, error: error)
        })
    }
    */
    
    func doGET(urlString: String, method: String, parameters: [String : AnyObject]?, headers: [String : String]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        var mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + method)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            print("headers = \(headers)")
            
            for header in headers {
                print("header.0 = \(header.0)")
                print("header.1 = \(header.1)")
                request.addValue(header.1, forHTTPHeaderField: header.0)
            }
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request (\(request.URL)) returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request (\(request.URL)) returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request (\(request.URL)) returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            print("About to parse data for \(request.URL)")
            
            // FIXME
            if urlString == "https://www.udacity.com/api/" {
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
        print("Parsing JSON...")
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