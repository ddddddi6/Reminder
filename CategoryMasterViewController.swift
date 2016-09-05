//
//  CategoryListViewController.swift
//  Reminder
//
//  Created by Dee on 3/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData

protocol MasterDelegate {
    func refreshTableView()
    func refreshMapView()
}

class CategoryMasterViewController: UIViewController, MasterDelegate {
    
    var managedObjectContext: NSManagedObjectContext
    //var currentReminder: NSMutableArray
    var currentCategory: NSMutableArray
    
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
            let categoryDetailViewController = segue.destinationViewController  as! CategoryDetailViewController
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
        categoryMap.showCategoryOnMap()

    }
    
    @IBAction func editTable(sender: UIBarButtonItem) {
        let categoryTable = self.childViewControllers[1] as! UITableViewController as! CategoryTableViewController
        categoryTable.editing = !categoryTable.editing
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

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
