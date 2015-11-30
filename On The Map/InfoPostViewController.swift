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
    let parseClient = ParseClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable user input on mapView
        self.mapView.zoomEnabled = false
        self.mapView.scrollEnabled = false
        self.mapView.userInteractionEnabled = false
        
        self.locationTextField.delegate = self
        
        initializeUI()
    }
    
    func initializeUI() {
        // Make our buttons nice and round
        self.configureRoundedButton(self.findButton)
        self.configureRoundedButton(self.submitButton)
        
        // Determine the view's default background color for later reuse
        self.defaultColor = self.view.backgroundColor
        
        // Configure transparency on submit container without impacting all child views
        submitContainer.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.2)
        
        // Set the UI state to show Location Entry View
        setUIState(.EnterLocation)
    }
    
    // Make a UIButton rounded and white
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
                    if let loc = p.location {
                        SharedData.currentStudent.latitude  = loc.coordinate.latitude
                        SharedData.currentStudent.longitude = loc.coordinate.longitude
                        SharedData.currentStudent.mapString = loc.description
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = loc.coordinate
                        annotation.title = loc.description
                        self.mapView.addAnnotation(annotation)
                        
                        // Zoom in to the annotation we just added
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
        if let url = self.urlTextField.text  {
            if url != PLACEHOLDER_URL_TEXT {
                SharedData.currentStudent.mediaURL = url
                SharedData.currentStudent.mapString = self.locationTextField.text!
                
                self.parseClient.createStudentLocation(SharedData.currentStudent, completionHandler: { (result, error) -> Void in
                    if (error == nil) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        self.showMessage("Error while attempting to create Student Location")
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
}

extension InfoPostViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}