//
//  ColorManager.swift
//  Reminder
//
//  Created by Dee on 9/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ColorManager: NSObject {

    static let colorManager = ColorManager()
    
    // change the category color, return UIColor value
    func changeColor(color:String) -> UIColor{
        switch color {
        case "purple":
            return UIColor(red: 166/255.0, green: 116/255.0, blue: 233/255.0, alpha: 1.0)
        case "blue":
            return UIColor(red: 77/255.0, green: 202/255.0, blue: 233/255.0, alpha: 1.0)
        case "green":
            return UIColor(red: 112/255.0, green: 215/255.0, blue: 89/255.0, alpha: 1.0)
        case "red":
            return UIColor(red: 254/255.0, green: 76/255.0, blue: 52/255.0, alpha: 1.0)
        case "orange":
            return UIColor(red: 249/255.0, green: 140/255.0, blue: 34/255.0, alpha: 1.0)
        case "pink":
            return UIColor(red: 248/255.0, green: 136/255.0, blue: 223/255.0, alpha: 1.0)
        case "yellow":
            return UIColor(red: 243/255.0, green: 242/255.0, blue: 103/255.0, alpha: 1.0)
        case "black":
            return UIColor.blackColor()
        default:
            return UIColor.blackColor()
        }
    }
}
