//
//  LeaveDetailPopUpViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 9/13/17.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import SwiftyJSON

class LeaveDetailPopUpViewController: UIViewController {

    
    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var labelTotalLeaveDays: UILabel!
    @IBOutlet weak var labelLeaveStatus: UILabel!
    @IBOutlet weak var labelFromDate: UILabel!
    @IBOutlet weak var labelToDate: UILabel!
    @IBOutlet weak var textViewReason: UITextView!
    
    var dataObject = JSON.null
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.settingValues()
    }
    
    func settingValues(){
        
        let total_days = self.dataObject["total_days"].intValue
        
        if total_days == 1 {
            self.labelTotalLeaveDays.text = "Leave for 1 Day"
        }else{
            self.labelTotalLeaveDays.text = "Leaves for \(total_days) Days"
        }
        
        //Status
        let status = self.dataObject["status"].stringValue
        
        if status == "approved" {
            
            self.labelLeaveStatus.text = "Status: Approved"
            self.imageViewBackground.image = UIImage.init(named: "approved_popup")
            self.btnClose.setImage(UIImage.init(named: "approved_cancel"), for: .normal)
            
        } else if status == "rejected" {
            
            self.labelLeaveStatus.text = "Status: Rejected"
            self.imageViewBackground.image = UIImage.init(named: "rejected_popup")
            self.btnClose.setImage(UIImage.init(named: "rejected_cancel"), for: .normal)
            
        } else {
            
            self.labelLeaveStatus.text = "Status: Pending"
            self.imageViewBackground.image = UIImage.init(named: "pending_popup")
            self.btnClose.setImage(UIImage.init(named: "pending_cancel"), for: .normal)
            
        }

        let date_from = self.dataObject["date_from"].stringValue
        let date_from_obj = AppData.getDateObjectFromString(withTime: date_from, andDateFormat: "yyyy-MM-dd")
        self.labelFromDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: date_from_obj)
        
        let date_to = self.dataObject["date_to"].stringValue
        let date_to_obj = AppData.getDateObjectFromString(withTime: date_to, andDateFormat: "yyyy-MM-dd")
        self.labelToDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: date_to_obj)
        
        self.textViewReason.text = self.dataObject["leave_reason"].stringValue
    }

    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}


/*
 {
 "_id": "2",
 "employee_id": "10",
 "leave_reason": "Esi he dil kr rha hai",
 "date_from": "2017-06-23",
 "date_to": "2017-06-23",
 "total_days": "1",
 "reason_id": "2",
 "created_on": "2017-06-23 15:45:45",
 "is_seen": "0",
 "reason": "Emergency"
 },

 */
