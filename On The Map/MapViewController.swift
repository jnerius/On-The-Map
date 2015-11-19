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
        
        self.configureOverlayLoadingView()
        self.loadStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadStudentLocations()
    }
    
    @IBAction func reloadTouch(sender: AnyObject) {
        reloadStudentLocations()
    }
    
    func loadStudentLocations() {
        self.enableLoadingOverlay()
        ParseClient.sharedInstance().getStudentLocations(nil, skip: nil, order: nil) { (studentLocations, error) -> Void in
            if let locations = studentLocations {
                SharedData.studentLocations = locations
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.addMapAnnotationsFromUserLocations(locations)
                    self.disableLoadingOverlay()
                })
            }
        }
    }
    
    func reloadStudentLocations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        loadStudentLocations()
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
        // Dispose of any resources that can be recreated.
    }
    
    func addMapAnnotationsFromUserLocations(userLocations: [StudentInformation]) {
        var annotations = [MKPointAnnotation]()
        
        for location in userLocations {
            let lat = CLLocationDegrees(location.latitude)
            let lon = CLLocationDegrees(location.longitude)
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    @IBAction func pinButtonPressed(sender: UIBarButtonItem) {
        print("Pin thingy pressed")
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
                app.openURL(NSURL(string: toOpen)!)
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
}