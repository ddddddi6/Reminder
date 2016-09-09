//
//  CategoryTableViewController.swift
//  Reminder
//
//  Created by Dee on 2/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData


class CategoryTableViewController: UITableViewController {

    var currentCategory: NSMutableArray
    var masterDelegate: MasterDelegate?
    var detailViewController: ReminderTableViewController? = nil
    
    required init?(coder aDecoder: NSCoder) {
        self.currentCategory = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //masterDelegate?.refreshView()
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
        case 0: return self.currentCategory.count
        case 1: return 1
        default: return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CategoryTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CategoryTableViewCell
            
        // Configure the cell...
        let c: Category = self.currentCategory[indexPath.row] as! Category
        cell.categoryTitle.text = c.title
        cell.categoryTitle.textColor = ColorManager.colorManager.changeColor(c.color!)
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
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            self.performSegueWithIdentifier("editCategorySegue", sender: self.currentCategory[index.row])
        }
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
            // Delete the row from the data source
            DataManager.dataManager.managedObjectContext!.deleteObject(self.currentCategory[indexPath.row] as! NSManagedObject)
            //Save the ManagedObjectContext
            do
            {
                try DataManager.dataManager.managedObjectContext!.save()
            }
            catch let error
            {
                print("Could not save Deletion \(error)")
            }

            self.currentCategory = DataManager.dataManager.getCategories()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        return [delete, edit]
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = currentCategory[fromIndexPath.row]
        currentCategory.removeObjectAtIndex(fromIndexPath.row)
        currentCategory.insertObject(itemToMove, atIndex: toIndexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if (segue.identifier == "editCategorySegue")
        {
            let theDestination: CategoryDetailViewController = (segue.destinationViewController as! UINavigationController).topViewController as! CategoryDetailViewController
            //let indexPath = tableView.indexPathForSelectedRow!
            
            //let c: Category = self.currentCategory[indexPath.row] as! Category
            theDestination.category = sender as! Category
            theDestination.masterDelegate = self.masterDelegate
            // Display category details screen
       }
       else if (segue.identifier == "showReminderList")
       {
        // display reminder list under this category
            if let indexPath = self.tableView.indexPathForSelectedRow {

                let theDestination = (segue.destinationViewController as! UINavigationController).topViewController as! ReminderTableViewController
                theDestination.catogory = currentCategory[indexPath.row] as! Category
            }
        }
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
