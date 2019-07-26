//
//  HistoryPopUpViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 12/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import SwiftyJSON

class HistoryPopUpViewController: UIViewController {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDay: UILabel!
    
    @IBOutlet weak var labelWorkingHours: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataObj: JSON = JSON.null
    
    var breakTimeInArray: JSON = JSON.null
    var breakTimeOutArray: JSON = JSON.null
    
    var requiredTimeInString = ""
    var requiredTimeOutString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        self.settingValues()
    }

    func settingValues() {
        
        let dateof = self.dataObj["dateof"].stringValue
        let dateObj = AppData.getDateObjectFromString(withTime: dateof, andDateFormat: "yyyy-MM-dd")
        let requiredDateString = AppData.getDateWithFormateString("dd MMMM yyyy", andDateObject: dateObj)
        let requiredDayString = AppData.getDateWithFormateString("EEEE", andDateObject: dateObj)
        
        self.labelDate.text = requiredDateString
        self.labelDay.text = requiredDayString
        self.breakTimeInArray = self.dataObj["breaks"]["break_time_in"]
        self.breakTimeOutArray = self.dataObj["breaks"]["break_time_out"]
        
        let time_in = self.dataObj["time_in"].stringValue
        
        let timeInObj = AppData.getDateObjectFromString(withTime: time_in, andDateFormat: "HH:mm:ss", andTimeZone: TimeZone.init(abbreviation: "UTC"))
        self.requiredTimeInString = AppData.getDateWithFormateString("hh:mm:ss a", andDateObject: timeInObj, andTimeZone: TimeZone.init(abbreviation: "UTC"))
        
        let time_out = self.dataObj["time_out"].stringValue
        
        if time_out != "" {
            
            let timeOutObj = AppData.getDateObjectFromString(withTime: time_out, andDateFormat: "HH:mm:ss", andTimeZone: TimeZone.init(abbreviation: "UTC"))
            
            self.requiredTimeOutString = AppData.getDateWithFormateString("hh:mm:ss a", andDateObject: timeOutObj, andTimeZone: TimeZone.init(abbreviation: "UTC"))
        
            
            //total time duration
            
            let total_time_duration = self.dataObj["total_time_duration"].stringValue
            print("total_time_duration: \(total_time_duration)")
            
            let timeInHrs = Int(total_time_duration.substring(with: 0 ..< 2))
            let timeInMin = Int(total_time_duration.substring(with: 3 ..< 5))
            let timeInSec = Int(total_time_duration.substring(with: 6 ..< 8))
            print("timeInSec: \(timeInSec!), timeInMin: \(timeInMin!), timeInHrs: \(timeInHrs!), ")
            
            self.labelWorkingHours.text = String(format: "%zdhrs, %zdmins, %zdsec", timeInHrs!, timeInMin!, timeInSec!)
            
        }else{
            self.requiredTimeOutString = "Remainig"
            self.labelWorkingHours.text = "-"
        }
        
        print("requiredTimeInString: \(self.requiredTimeInString), requiredTimeOutString: \(self.requiredTimeOutString)")
        
        
        
        
    }
   
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension HistoryPopUpViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.breakTimeInArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if indexPath.row == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let labelCheckIn = cell.contentView.viewWithTag(2) as! UILabel
            let labelCheckOut = cell.contentView.viewWithTag(4) as! UILabel
            labelCheckIn.text = self.requiredTimeInString
            labelCheckOut.text = self.requiredTimeOutString
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "breakCell", for: indexPath)
            
            let index = indexPath.row - 1
            let labelBreakTitle = cell.contentView.viewWithTag(1) as! UILabel
            let labelTotalBreakTime = cell.contentView.viewWithTag(2) as! UILabel
            let labelStartTime = cell.contentView.viewWithTag(3) as! UILabel
            let labelEndTime = cell.contentView.viewWithTag(4) as! UILabel
            
            labelBreakTitle.text = String(format: "Break %zd", indexPath.row )
            
            
            let time_in = self.breakTimeInArray[index].stringValue
            let time_out = self.breakTimeOutArray[index].stringValue
            
            let timeInObj = AppData.getDateObjectFromString(withTime: time_in, andDateFormat: "HH:mm:ss", andTimeZone: TimeZone.init(abbreviation: "UTC"))
            let reqTimeInString = AppData.getDateWithFormateString("hh:mm:ss a", andDateObject: timeInObj, andTimeZone: TimeZone.init(abbreviation: "UTC"))
            labelStartTime.text = "Start: " + reqTimeInString!
            
            var reqTimeOutString = "-"
            
            if time_out != "" {
                
                let timeOutObj = AppData.getDateObjectFromString(withTime: time_out, andDateFormat: "HH:mm:ss", andTimeZone: TimeZone.init(abbreviation: "UTC"))
                reqTimeOutString = AppData.getDateWithFormateString("hh:mm:ss a", andDateObject: timeOutObj, andTimeZone: TimeZone.init(abbreviation: "UTC"))
                
                let timeInterval = timeOutObj?.timeIntervalSince(timeInObj!)
                
                let timeInMins = Float(timeInterval!) / 60.0
                let timeInSec = Int(timeInterval!) % 60
                
                labelTotalBreakTime.text = String(format: "%.0fMins, %zdSec", timeInMins, timeInSec)
            
            }
            
            labelEndTime.text = "End: " + reqTimeOutString
            labelTotalBreakTime.text = ""
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
}
