//
//  Reminder+CoreDataProperties.swift
//  Reminder
//
//  Created by Dee on 4/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reminder {

    @NSManaged var title: String?
    @NSManaged var note: String?
    @NSManaged var deadline: NSDate?
    @NSManaged var isComplete: NSNumber?
    @NSManaged var category: NSManagedObject?

}
