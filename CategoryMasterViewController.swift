//
//  CategoryListViewController.swift
//  Reminder
//
//  Created by Dee on 3/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData
import MapKit

protocol MasterDelegate {
    func refreshTableView()
    func refreshMapView()
    func getTableView() -> UISplitViewController
}

class CategoryMasterViewController: UIViewController, MasterDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var managedObjectContext: NSManagedObjectContext
    var currentCategory: NSMutableArray
    var detailViewController: ReminderTableViewController? = nil
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCategory = NSMutableArray()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }

    @IBAction func addCategory(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addCategorySegue", sender: self)
    }

    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var viewSegment: UISegmentedControl!
    @IBOutlet var categoryList: UIView!
    @IBOutlet var categoryMap: UIView!
    @IBAction func segmentedMenu(sender: UISegmentedControl) {
        switch viewSegment.selectedSegmentIndex {
        case 0:
            UIView.animateWithDuration(0.5, animations: {
                self.categoryList.alpha = 1
                self.categoryMap.alpha = 0
            })
            refreshTableView()
            editButton.enabled = true
            break
        case 1:
            UIView.animateWithDuration(0.5, animations: {
                self.categoryList.alpha = 0
                self.categoryMap.alpha = 1
            })
            refreshMapView()
            editButton.enabled = false
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSegment.selectedSegmentIndex = 0
        
        locationManager.delegate = self
        
        setupGeofencing()
        

        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "TransitionToCategoryTableView") {
            let categoryTableViewController = segue.destinationViewController  as! CategoryTableViewController
            categoryTableViewController.currentCategory = getCategories()
            categoryTableViewController.masterDelegate = self
            // Pass data to secondViewController before the transition
        } else if (segue.identifier == "TransitionToCategoryMapView") {
            let categoryMapViewController = segue.destinationViewController  as! CategoryMapViewController
            categoryMapViewController.currentCategory = getCategories()
        } else if (segue.identifier == "addCategorySegue") {
            let categoryDetailViewController = (segue.destinationViewController as! UINavigationController).topViewController  as! CategoryDetailViewController
            //categoryDetailViewController.currentCategory = currentCategory
            categoryDetailViewController.masterDelegate = self
            // Pass data to secondViewController before the transition
        } 
    }
    
    func refreshTableView() {
        let categoryTable = self.childViewControllers[1] as! UITableViewController as! CategoryTableViewController
        categoryTable.currentCategory = getCategories()
        categoryTable.tableView.reloadData()
    }
    
    func refreshMapView() {
        let categoryMap = self.childViewControllers[0] as! CategoryMapViewController
        categoryMap.currentCategory = getCategories()
        if getCategories().count != 0 {
            categoryMap.showCategoryOnMap()
        }

    }
    
    func getTableView() -> UISplitViewController {
//        let categoryTable = self.childViewControllers[1] as! UITableViewController as! CategoryTableViewController
//        return categoryTable
        let view = self.splitViewController as! GlobalSplitViewController
        return view
    }
    
    @IBAction func editTable(sender: UIBarButtonItem) {
        let categoryTable = self.childViewControllers[1] as! UITableViewController as! CategoryTableViewController
        self.navigationItem.leftBarButtonItem = categoryTable.editButtonItem()

        if (categoryTable.editing) {
            self.editButtonItem().title = "Done"
            categoryTable.editing = !categoryTable.editing
            
        } else {
            self.editButtonItem().title = "Edit"
        }
    }
    
    func getCategories() -> NSMutableArray {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Category", inManagedObjectContext:
            self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        var result = NSArray?()
        do
        {
            result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if result!.count == 0
            {
                currentCategory = []
            }
            else
            {
                currentCategory = NSMutableArray(array: result!)
            }
        }
        catch
        {
            let fetchError = error as NSError
            print(fetchError)
        }
        return currentCategory
    }

    func checkReminderCompletion(c: Category) -> Bool{
        let reminders = NSMutableArray(array: (c.tasks?.allObjects as! [Reminder]))
        if reminders.count != 0 {
            for reminder in reminders {
                let r: Reminder = reminder as! Reminder
                if r.isComplete == false {
                    return true
                }
            }
        }
        return false
    }
    
    func setupGeofencing() {
        for category in currentCategory {
            let c: Category = category as! Category
            if checkReminderCompletion(c) == true {
                let region = (name:c.title, coordinate:CLLocationCoordinate2D(latitude: Double(c.latitude!), longitude: Double(c.longitude!)))
                // Setup geofence monitoring
                print("Monitoring \(region.name) region")
                // Using radius from center of location
                let geofence = CLCircularRegion(center: region.coordinate, radius: Double(c.radius!), identifier: region.name!)
                locationManager.startMonitoringForRegion(geofence)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region \(region.identifier)")
        
        // Notify the user when they have entered a region
        let title = "Entered new region"
        let message = "You have arrived at \(region.identifier)."
        
        if UIApplication.sharedApplication().applicationState == .Active {
            // App is active, show an alert
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            // App is inactive, show a notification
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = message
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.fireDate = NSDate()
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region \(region.identifier)")
        
        // Notify the user when they have entered a region
        let title = "Exit region"
        let message = "You have exited from \(region.identifier)."
        
        if UIApplication.sharedApplication().applicationState == .Active {
            // App is active, show an alert
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            // App is inactive, show a notification
            let notification = UILocalNotification()
            notification.alertTitle = title
            notification.alertBody = message
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.fireDate = NSDate()
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
