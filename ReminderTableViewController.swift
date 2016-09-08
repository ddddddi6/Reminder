//
//  ReminderTableViewController.swift
//  Reminder
//
//  Created by Dee on 5/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData

protocol ReminderListDelegate {
    func refreshTable()
}

class ReminderTableViewController: UITableViewController, ReminderListDelegate {

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var addReminderItem: UIBarButtonItem!
    
    var catogory: Category!
    var currentReminder: NSMutableArray
    
    
    required init?(coder aDecoder: NSCoder) {
        self.currentReminder = NSMutableArray()
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // check whether user has selected a catogory to display
        if (catogory != nil) {
            refreshTable()
            addReminderItem.enabled = true
        } else {
            self.infoLabel.text = " Please select a category"
            addReminderItem.enabled = false
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section)
        {
        case 0: return self.currentReminder.count
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ReminderTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ReminderTableViewCell
        
        // Configure the cell...
        let r: Reminder = self.currentReminder[indexPath.row] as! Reminder
        cell.reminderTitle.text = r.title
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY, HH:mm"
        if r.deadline != nil {
            let date = dateFormatter.stringFromDate(r.deadline!)
            cell.deadline.text = date
        } else {
            cell.deadline.text = "Not available"
        }

        // display overdued reminder entry in red, normal reminder entry in black
        if (r.deadline != nil && (r.deadline?.compare(NSDate())) == NSComparisonResult.OrderedAscending) {
            cell.reminderTitle.textColor = UIColor.redColor()
            cell.deadline.textColor = UIColor.redColor()
        } else {
            cell.reminderTitle.textColor = UIColor.blackColor()
            cell.deadline.textColor = UIColor.blackColor()
        }
        
        // display completed reminder entry in gray
        if r.isComplete == true {
            cell.reminderTitle.textColor = UIColor.grayColor()
            cell.deadline.textColor = UIColor.grayColor()
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        else{
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
            // Delete the row from the data source
            DataManager.dataManager.managedObjectContext!.deleteObject(self.currentReminder[indexPath.row] as! NSManagedObject)
            //Save the ManagedObjectContext
            do
            {
                try DataManager.dataManager.managedObjectContext!.save()
            }
            catch let error
            {
                print("Could not save Deletion \(error)")
            }
            
            self.currentReminder = DataManager.dataManager.getReminders(self.catogory)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        //self.refreshTable()
        return [delete]
    }
    
    // reload data
    func refreshTable() {
        self.title = catogory.title
        currentReminder = DataManager.dataManager.getReminders(catogory)
        if (currentReminder.count == 0) {
            self.infoLabel.text = "  There is no reminder"
        } else if (currentReminder.count == 1) {
            self.infoLabel.text = "  Here is " + String(currentReminder.count) + " Reminder"
        } else {
            self.infoLabel.text = "  Here Are " + String(currentReminder.count) + " Reminders"
        }
        sortReminderList ()
    }

    // add a new reminder entry
    @IBAction func addReminder(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addNewReminder", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "addNewReminder")
        {
            if catogory == nil {
                let messageString: String = "Please select a categoty first"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                    UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let theDestination: ReminderDetailViewController = segue.destinationViewController as! ReminderDetailViewController
                
                theDestination.category = catogory
                theDestination.delegate = self
            // Display new reminder screen
            }
        } else if (segue.identifier == "editReminder") {
            if catogory == nil {
                let messageString: String = "Please select a categoty first"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                    UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let indexPath = tableView.indexPathForSelectedRow!
                let r: Reminder = self.currentReminder[indexPath.row] as! Reminder
                let theDestination: ReminderDetailViewController = segue.destinationViewController as! ReminderDetailViewController
                theDestination.reminder = r 
                theDestination.category = catogory
                theDestination.delegate = self
                // Display reminder details screen
            }
        }
    }
    
    // sort the reminder list
    func sortReminderList () {
            currentReminder.sortUsingComparator({ (o1: AnyObject!, o2: AnyObject!) -> NSComparisonResult in
            let reminder1 = o1 as! Reminder
            let reminder2 = o2 as! Reminder
            if (reminder1.deadline != nil || reminder2.deadline != nil) {
                // reminder hasn't been completed should be placed at first
                if (reminder1.isComplete!.boolValue && !reminder2.isComplete!.boolValue) {
                    return .OrderedDescending
                } else if (!reminder1.isComplete!.boolValue && reminder2.isComplete!.boolValue) {
                    return .OrderedAscending
                }
                // reminder contains a due date should be palced at first
                if (reminder1.deadline != nil && reminder2.deadline == nil) {
                    return .OrderedAscending
                } else if (reminder1.deadline == nil && reminder2.deadline != nil) {
                    return .OrderedDescending
                }
                return reminder1.deadline!.compare(reminder2.deadline!)
                }
                return .OrderedAscending
        })
        self.tableView.reloadData()
    }
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
