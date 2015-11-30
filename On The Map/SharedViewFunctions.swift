//
//  SharedViewFunctions.swift
//  On The Map
//
//  Created by Josh on 11/21/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit

extension UIViewController {
    func showMessage(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            self.showViewController(alert, sender: self)
        })
    }
    
    func showError(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            print("showError: encountered error \(message)")
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
}