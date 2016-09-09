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
    func popupEnterAlert(didEnterRegion region: CLRegion)
    func popupExitAlert(didExitRegion region: CLRegion)
}

class CategoryMasterViewController: UIViewController, MasterDelegate, CLLocationManagerDelegate {
    
    var currentCategory: NSMutableArray
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCategory = NSMutableArray()
        super.init(coder: aDecoder)
    }

    // add a new category
    @IBAction func addCategory(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addCategorySegue", sender: self)
    }

    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var viewSegment: UISegmentedControl!
    @IBOutlet var categoryList: UIView!
    @IBOutlet var categoryMap: UIView!
    
    // listen for switching viewsa
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
        
        DataManager.dataManager.delegate = self
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "TransitionToCategoryTableView") {
            let categoryTableViewController = segue.destinationViewController  as! CategoryTableViewController
            categoryTableViewController.currentCategory = DataManager.dataManager.getCategories()
            categoryTableViewController.masterDelegate = self
            // Pass data to secondViewController before the transition
        } else if (segue.identifier == "TransitionToCategoryMapView") {
            let categoryMapViewController = segue.destinationViewController  as! CategoryMapViewController
            categoryMapViewController.currentCategory = DataManager.dataManager.getCategories()
        } else if (segue.identifier == "addCategorySegue") {
            let categoryDetailViewController = (segue.destinationViewController as! UINavigationController).topViewController  as! CategoryDetailViewController
            categoryDetailViewController.masterDelegate = self
            // Pass data to secondViewController before the transition
        } 
    }
    
    // refresh child tableviwe
    func refreshTableView() {
        let categoryTable = self.childViewControllers[1] as! UITableViewController as! CategoryTableViewController
        categoryTable.currentCategory = DataManager.dataManager.getCategories()
        categoryTable.tableView.reloadData()
    }
    
    // refresh child mapview
    func refreshMapView() {
        let categoryMap = self.childViewControllers[0] as! CategoryMapViewController
        categoryMap.currentCategory = DataManager.dataManager.getCategories()
        if DataManager.dataManager.getCategories().count != 0 {
            categoryMap.showCategoryOnMap()
        }

    }
    
    // edit table for rearranging the order
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
    
    // Popup an alert for user when the application is active
    func popupEnterAlert(didEnterRegion region: CLRegion) {
        // Notify the user when they have entered a region
        let message = "There are tasks need to be done at \(region.identifier)."
        let title = "Reminder"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func popupExitAlert(didExitRegion region: CLRegion) {
        // Notify the user when they have entered a region
        let message = "Did you finish all tasks at \(region.identifier)?"
        let title = "Reminder"
        
        if UIApplication.sharedApplication().applicationState == .Active {
            // App is active, show an alert
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
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
