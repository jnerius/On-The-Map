//
//  LoginViewController.swift
//  On The Map
//
//  Created by Josh on 11/2/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let udacityClient = UdacityClient()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginTouch(sender: UIButton) {
        print("loginTouch")
        
        // FIXME - shortcut the login process for now
        self.usernameTextField.text = "a"
        self.passwordTextField.text = "b"
        
        if (usernameTextField.text != "" && passwordTextField.text != "") {
            self.doLogin(self.usernameTextField.text!, password: self.passwordTextField.text!)
        } else {
            showError("You must specify username/password")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME - shortcut the login process
        dispatch_async(dispatch_get_main_queue(), {
            self.doLogin("", password: "")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeUI() {
        
    }
    
    func styleUsernameField() {
        
    }
    
    func stylePasswordField() {
        
    }
    
    func showError(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            print("showError: encountered error \(message)")
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            self.showViewController(alert, sender: self)
        })
    }
    
    func doLogin(username: String, password: String) {
        // FIXME - shortcut the login process for now
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapTabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
        SharedData.currentStudent.firstName = "Josh"
        SharedData.currentStudent.lastName = "Nerius"
        SharedData.currentStudent.uniqueKey = "u998045"
        
        /*
        udacityClient.authenticate(username, password: password) { (result, error) -> Void in
            
            if let result = result {
                if let account = result["account"] as? [String:AnyObject] {
                    if let key = account["key"] as? String {
                        self.udacityClient.getUserData(key, completionHandler: { (userData, error) -> Void in
                            print(userData)
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        print("in async block")
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapTabBarController") as! UITabBarController
                        self.presentViewController(controller, animated: true, completion: nil)
                    })
                }
            } else {
                self.showError("Invalid Email or Password")
            }
        }
        */
    }
}