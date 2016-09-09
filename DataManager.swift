//
//  DataManager.swift
//  Reminder
//
//  Created by Dee on 8/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class DataManager: NSObject, CLLocationManagerDelegate {
    
    static let dataManager = DataManager()
    
    let locationManager = CLLocationManager()
    
    var managedObjectContext: NSManagedObjectContext?
    
    var delegate: MasterDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        // Ask user for permission to use location
        // Uses description from NSLocationAlwaysUsageDescription in Info.plist
        locationManager.requestAlwaysAuthorization()
    }

    // save data to CoreData
    func saveData() {
        if self.managedObjectContext!.hasChanges {
            do {
                try self.managedObjectContext!.save()
                setupGeofencing()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // get category list
    func getCategories() -> NSMutableArray {
        var currentCategory: NSMutableArray!
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Category", inManagedObjectContext:
            self.managedObjectContext!)
        fetchRequest.entity = entityDescription
        
        var result = NSArray?()
        do
        {
            result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
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
    
    // get reminder list
    func getReminders(category: Category) -> NSMutableArray {
        var currentReminder: NSMutableArray!
        let result = category.tasks?.allObjects as! [Reminder]
        if result.count == 0
        {
            currentReminder = []
        }
        else
        {
            currentReminder = NSMutableArray(array: result)
        }
        return currentReminder
    }

    // set up geofencing
    func setupGeofencing() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoringForRegion(region)
        }
        for category in getCategories() {
            let c: Category = category as! Category
            print (c.isRemind)
            print(checkReminderCompletion(c))
            if (c.isRemind == true && checkReminderCompletion(c) == true) {
                let region = (name:c.title, coordinate:CLLocationCoordinate2D(latitude: Double(c.latitude!), longitude: Double(c.longitude!)))
                // Setup geofence monitoring
                print("Monitoring \(region.name) region")
                // Using radius from center of location
                let geofence = CLCircularRegion(center: region.coordinate, radius: Double(c.radius!), identifier: region.name!)
                locationManager.startMonitoringForRegion(geofence)
            }
        }
    }
    
    // check the completion status of reminder
    func checkReminderCompletion(c: Category) -> Bool{
        let reminders = DataManager.dataManager.getReminders(c)
        if reminders.count != 0 {
            for reminder in reminders {
                let r: Reminder = reminder as! Reminder
                if (!(r.isComplete?.boolValue)!) {
                    return true
                } else {
                    continue
                }
            }
        }
        print (reminders.count)
        return false
    }


    // Arrive at the region
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region \(region.identifier)")
        
        // Notify the user when they have entered a region
        let message = "There are tasks need to be done at \(region.identifier)."
        let title = "Reminder"
        
        if UIApplication.sharedApplication().applicationState == .Active {
            // App is active, show an alert
            delegate!.popupEnterAlert(didEnterRegion: region)
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
    
    // Exit from the region
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region \(region.identifier)")
        
        // Notify the user when they have exited from a region
        let title = "Reminder"
        let message = "Did you finish all tasks at \(region.identifier)?"
        
        if UIApplication.sharedApplication().applicationState == .Active {
           // App is active, show an alert
            delegate!.popupExitAlert(didExitRegion: region)
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

}
