//
//  ViewController.swift
//  On The Map
//
//  Created by Josh on 11/1/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var overlayLoadingView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let parseClient = ParseClient.sharedInstance()
    var mapRenderingInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the overlay / loading view
        self.configureOverlayLoadingView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Every time the view appears, reload student locations
        reloadStudentLocations()
    }
    
    @IBAction func reloadTouch(sender: AnyObject) {
        reloadStudentLocations()
    }
    
    @IBAction func logoutTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadStudentLocations() {
        // Enable the loading overlay before we start loading students
        self.enableLoadingOverlay()
        
        // Call into Parse Client
        ParseClient.sharedInstance().getStudentLocations(nil, skip: nil, order: nil) { (studentLocations, error) -> Void in
            if error == nil {
                if let locations = studentLocations {
                    // Store the locations for later use
                    SharedData.studentLocations = locations
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.addMapAnnotationsFromUserLocations(locations)
                        self.disableLoadingOverlay()
                    })
                }
            } else {
                self.showError("Error loading student locations")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.disableLoadingOverlay()
                })
            }
        }
    }
    
    func reloadStudentLocations() {
        // First, remove all current annotations from the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // Now, load the locations
        self.loadStudentLocations()
    }
    
    func configureOverlayLoadingView() {
        self.overlayLoadingView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
    }
    
    func enableLoadingOverlay() {
        self.overlayLoadingView.hidden = false
    }
    
    func disableLoadingOverlay() {
        if (!self.mapRenderingInProgress) {
            self.overlayLoadingView.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addMapAnnotationsFromUserLocations(userLocations: [StudentInformation]) {
        var annotations = [MKPointAnnotation]()
        
        // Loop through the student locations, and set up an annotation for each
        for location in userLocations {
            let annotation = self.annotationFromUserLocation(location)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    // Convert a Student Location to an Annotation
    func annotationFromUserLocation(location: StudentInformation) -> MKPointAnnotation {
        let lat = CLLocationDegrees(location.latitude)
        let lon = CLLocationDegrees(location.longitude)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        annotation.title = "\(location.firstName) \(location.lastName)"
        annotation.subtitle = location.mediaURL
        
        return annotation
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped...")
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if let url = NSURL(string: toOpen) {
                    if self.urlIsValid(url) {
                        app.openURL(url)
                    } else {
                        showError("Invalid URL")
                    }
                } else {
                    showError("Invalid URL")
                }
            }
        }
    }
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        self.mapRenderingInProgress = true
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        self.mapRenderingInProgress = false
        self.disableLoadingOverlay()
    }
    
    func urlIsValid(url: NSURL) -> Bool {
        return UIApplication.sharedApplication().canOpenURL(url)
    }
}