//
//  Category+CoreDataProperties.swift
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

extension Category {

    @NSManaged var title: String?
    @NSManaged var color: String?
    @NSManaged var priority: NSNumber?
    @NSManaged var isRemind: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var latitude: NSNumber?
    @NSManaged var address: String?
    @NSManaged var radius: NSNumber?
    @NSManaged var tasks: NSSet?

}
