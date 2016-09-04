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
    func refreshView()
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

    @IBOutlet var categoryList: UIView!
    @IBOutlet var categoryMap: UIView!
    @IBAction func segmentedMenu(sender: UISegmentedControl) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "TransitionToCategoryTableView") {
            let categoryTableViewController = segue.destinationViewController  as! CategoryTableViewController
            categoryTableViewController.currentCategory = currentCategory
            categoryTableViewController.masterDelegate = self
            // Pass data to secondViewController before the transition
        }
    }
    
    func refreshView() {
        let categoryTable = self.childViewControllers[1] as! UITableViewController
        categoryTable.tableView.reloadData()
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
