//
//  InfoPostViewController.swift
//  On The Map
//
//  Created by Josh on 11/2/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit
import MapKit

enum UIState {
    case EnterLocation
    case EnterURL
}

class InfoPostViewController : UIViewController {
    let PLACEHOLDER_URL_TEXT = "Enter a Link to Share Here"
    let PLACEHOLDER_LOC_TEXT = "Enter Your Location Here"
    
    let parseClient = ParseClient.sharedInstance()
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var enterLocationView: UIView!
    @IBOutlet weak var enterURLView: UIView!
    @IBOutlet weak var enterLinkSubview: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitContainer: UIView!
    
    var defaultColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable user input on mapView
        self.mapView.zoomEnabled = false
        self.mapView.scrollEnabled = false
        self.mapView.userInteractionEnabled = false
        
        self.defaultColor = self.view.backgroundColor
        self.locationTextField.delegate = self
        
        initializeUI()
    }
    
    func initializeUI() {
        setUIState(.EnterLocation)
        configureRoundedButton(self.findButton)
        configureRoundedButton(self.submitButton)
        
        // Configure transparency on submit container without impacting all child views
        submitContainer.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.2)
    }
    
    func configureRoundedButton(button: UIButton) {
        button.backgroundColor = UIColor.whiteColor()
        button.alpha = 1
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func cancelTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findTouch(sender: AnyObject) {
        let locationString = self.locationTextField.text!
        
        CLGeocoder().geocodeAddressString(locationString) { (placemarks, error) -> Void in
            if let placemarks = placemarks {
                for p in placemarks {
                    print(p)
                    if let loc = p.location {
                        print(loc)
                        SharedData.currentStudent.latitude = loc.coordinate.latitude
                        SharedData.currentStudent.longitude = loc.coordinate.longitude
                        SharedData.currentStudent.mapString = loc.description
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = loc.coordinate
                        annotation.title = loc.description
                        self.mapView.addAnnotation(annotation)
                        
                        var region = MKCoordinateRegion()
                        region.center = loc.coordinate
                        region.span.latitudeDelta = 0.2
                        region.span.longitudeDelta = 0.2
                        
                        self.mapView.setRegion(region, animated: true)
                        
                        self.setUIState(.EnterURL)
                    }
                }
            } else {
                print("COULD NOT FIND LOCATION")
                self.showMessage("Could not find location")
            }
        }
    }
    
    @IBAction func submitTouch(sender: AnyObject) {
        print("submitTouch")
        if let url = self.urlTextField.text  {
            if url != PLACEHOLDER_URL_TEXT {
                SharedData.currentStudent.mediaURL = url
                
                self.parseClient.createStudentLocation(SharedData.currentStudent, completionHandler: { (result, error) -> Void in
                    if (error == nil) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            } else {
                self.showMessage("You must enter a URL")
            }
        } else {
            self.showMessage("You must enter a URL")
        }
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
    
    func showMessage(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            self.showViewController(alert, sender: self)
        })
    }
}

extension InfoPostViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}