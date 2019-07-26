//
//  NotificationTableViewCell.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/24/18.
//  Copyright © 2018 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
