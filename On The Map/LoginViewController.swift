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
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTouch(sender: UIButton) {
        if (usernameTextField.text != "" && passwordTextField.text != "") {
            self.doLogin(self.usernameTextField.text!, password: self.passwordTextField.text!)
        } else {
            showError("You must specify username/password")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear out the username/password fields
        self.usernameTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginDidBegin() {
        self.disableInput()
        self.enableSpinner()
    }
    
    func loginDidEnd() {
        dispatch_async(dispatch_get_main_queue()) {
            self.enableInput()
            self.disableSpinner()
        }
    }
    
    func enableSpinner() {
        self.activitySpinner.startAnimating()
    }
    
    func disableSpinner() {
        self.activitySpinner.stopAnimating()
    }
    
    func disableInput() {
        self.usernameTextField.enabled = false
        self.passwordTextField.enabled = false
        self.loginButton.enabled = false
    }
    
    func enableInput() {
        self.usernameTextField.enabled = true
        self.passwordTextField.enabled = true
        self.loginButton.enabled = true
    }
    
    func doLogin(username: String, password: String) {
        
        self.loginDidBegin()
        
        udacityClient.authenticate(username, password: password) { (result, error) -> Void in
            
            if let error = error {
                // Per submission 1 review, properly handling authentication errors
                self.loginDidEnd()
                self.showError(error.localizedDescription)
            } else if let result = result {
                if let account = result["account"] as? [String:AnyObject] {
                    if let key = account["key"] as? String {
                        self.udacityClient.getUserData(key, completionHandler: { (userData, error) -> Void in
                            print("User data: \(userData)")
                            
                            SharedData.loggedInUser = userData
                            SharedData.currentStudent.firstName = userData.firstName
                            SharedData.currentStudent.lastName  = userData.lastName
                            SharedData.currentStudent.uniqueKey = userData.userId
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                self.loginDidEnd()
                                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapTabBarController") as! UITabBarController
                                self.presentViewController(controller, animated: true, completion: nil)
                            })
                        })
                    }
                }
            } else {
                self.loginDidEnd()
                self.showError((error?.localizedDescription)!)
            }
        }
    }
}