//
//  InfoPostViewController.swift
//  On The Map
//
//  Created by Josh on 11/2/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit

enum UIState {
    case EnterLocation
    case EnterURL
}

class InfoPostViewController : UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var enterLocationView: UIView!
    @IBOutlet weak var enterURLView: UIView!
    @IBOutlet weak var enterLinkSubview: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var defaultColor: UIColor?
    
    @IBAction func cancelTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findTouch(sender: AnyObject) {
        setUIState(.EnterURL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultColor = self.view.backgroundColor
        self.locationTextField.delegate = self
        
        setUIState(.EnterLocation)
    }
    
    func setUIState(state: UIState) {
        if state == .EnterLocation {
            self.enterLocationView.hidden = false
            self.enterURLView.hidden = true
            self.view.backgroundColor = self.defaultColor
        } else if state == .EnterURL {
            self.enterURLView.hidden = false
            self.enterLocationView.hidden = true
            self.view.backgroundColor = self.enterLinkSubview.backgroundColor
            self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
    }
}

extension InfoPostViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}