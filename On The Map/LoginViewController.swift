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
    
    func doLogin(username: String, password: String) {
        
        udacityClient.authenticate(username, password: password) { (result, error) -> Void in
            
            if let result = result {
                if let account = result["account"] as? [String:AnyObject] {
                    if let key = account["key"] as? String {
                        self.udacityClient.getUserData(key, completionHandler: { (userData, error) -> Void in
                            print("User data: \(userData)")
                            
                            SharedData.loggedInUser = userData
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapTabBarController") as! UITabBarController
                                self.presentViewController(controller, animated: true, completion: nil)
                            })
                        })
                    }
                }
            } else {
                self.showError("Invalid Email or Password")
            }
        }
    }
}