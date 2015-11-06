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
    let parseClient = ParseClient.sharedInstance()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If there is no student information, retrieve it now.
        if SharedData.studentLocations.count == 0 {
            self.parseClient.getStudentLocations(nil, skip: nil, order: nil) { (studentLocations, error) -> Void in
                if let locations = studentLocations {
                    SharedData.studentLocations = locations
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.addMapAnnotationsFromUserLocations(SharedData.studentLocations(false))
        })

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
}