//
//  ReminderDetailViewController.swift
//  Reminder
//
//  Created by Dee on 6/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData

class ReminderDetailViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var noteField: UITextView!
    @IBOutlet var completionSwitch: UISwitch!
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var completionLabel: UILabel!
    
    var reminder: Reminder!
    var delegate: ReminderListDelegate!
    var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        noteField.layer.borderWidth = 1.0
        noteField.layer.cornerRadius = 5

        completionSwitch.enabled = true
        // check the mode of this controller, new or edit
        if reminder == nil {
            self.title = "New Reminder"
            completionLabel.hidden = true
            completionSwitch.hidden = true
            datePicker.hidden = true
        } else {
            completionLabel.hidden = false
            completionSwitch.hidden = false
            self.title = "Edit Reminder"
            showReminderDetail()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // when the controller is for editing, then display the reminder detials for user
    func showReminderDetail() {
        self.titleField.text = reminder.title
        if reminder.deadline != nil {
            self.reminderSwitch.setOn(true, animated: true)
            datePicker.enabled = true
            datePicker.hidden = false
            self.datePicker.date = reminder.deadline!
        } else {
            self.datePicker.enabled = false
            datePicker.hidden = true
            self.reminderSwitch.setOn(false, animated: true)
        }
        self.noteField.text = reminder.note
        if reminder.isComplete == true {
            completionSwitch.setOn(true, animated: true)
        } else {
            completionSwitch.setOn(false, animated: true)
        }
    }
    
    // let user to choose whether enable due date
    @IBAction func setDeadline(sender: UISwitch) {
        if reminderSwitch.on {
            datePicker.enabled = true
            datePicker.hidden = false
        } else {
            datePicker.enabled = false
            datePicker.hidden = true
        }
    }
    
    // save the input
    @IBAction func doneAction(sender: UIBarButtonItem) {
        let reminderTitle = self.titleField.text
        let deadline : NSDate?
        if reminderSwitch.on {
            deadline = self.datePicker.date
        } else {
            deadline = nil
        }
        let note = self.noteField.text
        let isComplete = self.completionSwitch.on
        
        // check input validation
        if(reminderTitle!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "")
        {
            let messageString: String = "Please input a valid reminder title"
            // Setup an alert to warn user
            // UIAlertController manages an alert instance
            let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle:
                UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            if (reminder == nil) {
                reminder = (NSEntityDescription.insertNewObjectForEntityForName("Reminder",
                    inManagedObjectContext: DataManager.dataManager.managedObjectContext!) as? Reminder)!
            }
            reminder.title = reminderTitle
            reminder.deadline = deadline
            reminder.isComplete = isComplete
            reminder.note = note
            category.addReminder(reminder)
            DataManager.dataManager.saveData()
            if reminder.deadline != nil {
                pushNotification(reminder.deadline!)
            }
            delegate?.refreshTable()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }

    // push notification when reminder due
    func pushNotification(deadline: NSDate) {
        // create a corresponding local notification
        let notification = UILocalNotification()
        //notification.alertTitle = title
        notification.alertBody = "You have task due now."
        notification.alertAction = "open"
        notification.fireDate = deadline
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // cancel the input and back to previous controller
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // dismiss keyboard for text field
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
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
