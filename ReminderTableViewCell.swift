//
//  ReminderTableViewCell.swift
//  Reminder
//
//  Created by Dee on 6/09/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet var deadline: UILabel!
    @IBOutlet var reminderTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
