//
//  ViewController.swift
//  On The Map
//
//  Created by Josh on 11/1/15.
//  Copyright © 2015 Josh Nerius. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let parseClient = ParseClient.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // If there is no student information, retrieve it now.
        SharedData.studentLocations(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func refreshTouch(sender: AnyObject) {
        ParseClient.sharedInstance().getStudentLocations(nil, skip: nil, order: nil) { (studentLocations, error) -> Void in
            if let error = error {
                self.showError(error.localizedDescription)
            } else {
                if let locations = studentLocations {
                    // Store the locations for later use
                    SharedData.studentLocations = locations
                
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }

    @IBAction func logoutTouch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedData.studentLocations(false).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let location = SharedData.studentLocations(false)[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentInformationCell") as? StudentLocationTableViewCell

        cell?.studentNameLabel.text = "\(location.firstName) \(location.lastName)"
        cell?.studentUrlLabel.text = location.mediaURL
        
        if let cell = cell {
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension TableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = SharedData.studentLocations(false)[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        let toOpen = studentInfo.mediaURL
        if let url = NSURL(string: toOpen) {
            app.openURL(url)
        }
    }
}