//
//  HistoryViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 08/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MessageUI
import SDWebImage
import Foundation

class HistoryViewController: UIViewController, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    
    //History By
    @IBOutlet weak var labelHistoryType: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    let historyTypes = ["Month", "Dates"]
    let months = [["title":"January", "value":"01"], ["title":"February", "value":"02"], ["title":"March", "value":"03"], ["title":"April", "value":"04"], ["title":"May", "value":"05"], ["title":"June", "value":"06"], ["title":"July", "value":"07"], ["title":"August", "value":"08"], ["title":"September", "value":"09"], ["title":"October", "value":"10"], ["title":"November", "value":"11"], ["title":"December", "value":"12"]]
    
    //Date Selection
    @IBOutlet weak var viewSelectDates: UIView!
    var viewSelectDatesHeight: CGFloat = 0.0
    @IBOutlet weak var heightConstraintViewSelectDate: NSLayoutConstraint!
    @IBOutlet weak var labelFromDate: UILabel!
    @IBOutlet weak var labelToDate: UILabel!
    var isFromDateSelected = true
    
    //Month
    @IBOutlet weak var labelSelectMonth: UILabel!
    @IBOutlet weak var viewMonth: UIView!
    @IBOutlet weak var btnFilterMonth: UIButton!
    var selectedMonth = ""
    var selectedMonthName = ""
    
    //Date Picker
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    var isShowHistoryByPicker = true
    var isShowMonthPicker = true
    
    @IBOutlet weak var tableView: UITableView!
    var historyArray: JSON = JSON.null
    @IBOutlet weak var labelNoHistoryFound: UILabel!
    
    @IBOutlet weak var btnPDF: UIButton!
    
    //Reporting
    @IBOutlet weak var labelTotalHoursGivenTitle: UILabel!
    @IBOutlet weak var labelTotalHoursGiven: UILabel!
    @IBOutlet weak var labelTotalHoursRequiredTitle: UILabel!
    @IBOutlet weak var labelTotalHoursRequired: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var labelTotalHoursRemainigTitle: UILabel!
    @IBOutlet weak var labelTotalHoursRemainig: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        // Do any additional setup after loading the view.
        self.selectedMonth = AppData.getDateWithFormateString("MM", andDateObject: Date())
        self.selectedMonthName = AppData.getDateWithFormateString("MMMM", andDateObject: Date())
        self.labelMonth.text = self.selectedMonthName
        self.labelFromDate.text = "01/" + AppData.getDateWithFormateString("MM/yyyy", andDateObject: Date())
        self.labelToDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: Date())
        
        self.viewSelectDatesHeight = self.heightConstraintViewSelectDate.constant
        self.heightConstraintViewSelectDate.priority = UILayoutPriority(rawValue: 1000)
        self.heightConstraintViewSelectDate.constant = 0.0
        self.viewSelectDates.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        if (AppDataSwift.defaults.object(forKey: "historyArray") != nil) {
//
//            self.labelFromDate.text = "\(AppDataSwift.defaults.object(forKey: "fromDate")!)"
//            self.labelToDate.text = "\(AppDataSwift.defaults.object(forKey: "toDate")!)"
//
//            let data = NSKeyedUnarchiver.unarchiveObject(with: AppDataSwift.defaults.object(forKey: "historyArray") as! Data)
//            self.historyArray = JSON(data!)
//
//            print("historyArray: \(self.historyArray)")
//
//            self.tableView.reloadData()
//            self.calculateTotalTime(withDataArray: self.historyArray)
//
//        }else{
        
            if AppDataSwift.isWifiConnected {
                AppDataSwift.showLoader("", andViewController: self)
                self.getAttendance()
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
//        }
        
        self.setInfoView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
    }
    
    func setTopBar(){
        
        AppData.setBorderWith(self.imageViewEmpPic, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: self.imageViewEmpPic.frame.size.height / 2.0 )
        
        let name = "\(AppDataSwift.defaults.object(forKey: "name")!)"
        let profile_pic = "\(AppDataSwift.defaults.object(forKey: "profile_pic")!)"
        
        self.labelHi.text = "Hi \(name)!"
        
        let placeHolderImage = AppData.imageSnapshot(fromText: name, backgroundColor: AppData.color(fromHexString: "#F96612", andAlpha: 1.0), foreGroundColor: .white, circular: true, textAttributes: nil, andImageView: self.imageViewEmpPic)
        
        if profile_pic != "" {
            let url = URL.init(string: profile_pic)
            let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
                if let image = image {
                    if image.isPortrait() {
                        self.imageViewEmpPic.image = image.scaled(toHeight: self.imageViewEmpPic.frame.size.height * 2)
                    }else{
                        self.imageViewEmpPic.image = image.scaled(toWidth: self.imageViewEmpPic.frame.size.width * 2)
                    }
                }
            }
            self.imageViewEmpPic.sd_setImage(with: url, completed: block)
        }else{
            self.imageViewEmpPic.image = placeHolderImage
        }
        
    }
    
    func setInfoView(){
        if self.historyArray.count > 0 {
            self.tableView.isHidden = false
            self.labelNoHistoryFound.isHidden = true
            self.btnPDF.isHidden = false
        }else{
            self.tableView.isHidden = true
            self.labelNoHistoryFound.isHidden = false
            self.btnPDF.isHidden = true
        }
    }
    
    @IBAction func btnTopLogoAction(_ sender: Any) {
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnEmployeeImageAction(_ sender: Any) {
        AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnProfileAction(_ sender: Any) {
        AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnHistoryAction(_ sender: Any) {
//        AppDataSwift.gotoHistoryScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnAboutAction(_ sender: Any) {
        AppDataSwift.gotoLeaveScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    //MARK: History Type
    @IBAction func btnHistoryTypeAction(_ sender: Any) {
        self.isShowHistoryByPicker = true
        self.isShowMonthPicker = false
        self.viewDatePicker.isHidden = false
        self.pickerView.isHidden = false
        self.datePicker.isHidden = true
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func btnMonthAction(_ sender: Any) {
        self.isShowHistoryByPicker = false
        self.isShowMonthPicker = true
        self.viewDatePicker.isHidden = false
        self.pickerView.isHidden = false
        self.datePicker.isHidden = true
        self.pickerView.reloadAllComponents()
    }
    
    //MARK: - Dates
    
    @IBAction func btnFromDateAction(_ sender: Any) {
        self.isFromDateSelected = true
        self.isShowHistoryByPicker = false
        self.isShowMonthPicker = false
        self.viewDatePicker.isHidden = false
        self.pickerView.isHidden = true
        self.datePicker.isHidden = false
    }
    
    @IBAction func btnToDateAction(_ sender: Any) {
        self.isFromDateSelected = false
        self.isShowHistoryByPicker = false
        self.isShowMonthPicker = false
        self.viewDatePicker.isHidden = false
        self.pickerView.isHidden = true
        self.datePicker.isHidden = false
    }
    
    @IBAction func btnFilterAction(_ sender: Any) {
        if AppDataSwift.isWifiConnected {
            AppDataSwift.showLoader("", andViewController: self)
            self.getAttendance()
        }else{
            AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
        }
    }
    
    
    //MARK: - Date Picker
    
    @IBAction func btnDoneAction(_ sender: Any) {
        self.viewDatePicker.isHidden = true
        
        if self.isShowHistoryByPicker || self.isShowMonthPicker {
            let row = self.pickerView.selectedRow(inComponent: 0)
            if self.isShowHistoryByPicker{
                self.labelHistoryType.text = self.historyTypes[row]
                if row == 0 {
                    self.labelSelectMonth.isHidden = false
                    self.viewMonth.isHidden = false
                    self.btnFilterMonth.isHidden = false
                    self.heightConstraintViewSelectDate.constant = 0.0
                    self.viewSelectDates.isHidden = true
                }else{
                    self.labelSelectMonth.isHidden = true
                    self.viewMonth.isHidden = true
                    self.btnFilterMonth.isHidden = true
                    self.heightConstraintViewSelectDate.constant = self.viewSelectDatesHeight
                    self.viewSelectDates.setNeedsLayout()
                    self.viewSelectDates.isHidden = false
                }
            }else{
                self.selectedMonth = "\(self.months[row]["value"]!)"
                self.selectedMonthName = "\(self.months[row]["title"]!)"
                self.labelMonth.text = self.months[row]["title"]
            }
            
        }else{
            if self.isFromDateSelected {
                self.labelFromDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: self.datePicker.date)
            } else {
                self.labelToDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: self.datePicker.date)
            }
        }
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.viewDatePicker.isHidden = true
    }
    
    //MARK: - PDF
    @IBAction func btnPDFAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "PDF File Generated!", message: "Your Attendance History Detail's file has been successfully printed to a PDF file. What do you want to do now?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let actionPreview = UIAlertAction(title: "Preview", style: UIAlertAction.Style.default) { (action) in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PreviewPDFViewController") as! PreviewPDFViewController
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            
        }
        
        let actionEmail = UIAlertAction(title: "Email", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                
                let path = "\(NSTemporaryDirectory())history_file.pdf"
                let subject = "Attendance History from \(self.labelFromDate.text!) to \(self.labelToDate.text!)"
                
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeViewController = MFMailComposeViewController()
                    mailComposeViewController.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
                    mailComposeViewController.delegate = self
                    mailComposeViewController.setSubject(subject)
                    mailComposeViewController.addAttachmentData(NSData(contentsOfFile: path)! as Data, mimeType: "application/pdf", fileName: "AttendanceHistory")
                    self.present(mailComposeViewController, animated: true, completion: nil)
                }
                
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionCancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnManualAttendanceAction(_ sender: Any) {
 
        AppDataSwift.gotoManualAttendanceScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            break
        case .saved:
            break
        case .sent:
            AppDataSwift.showAlert("Sent!", andMsg: "Email has been sent successfully.", andViewController: self)
            break
        case .failed:
            AppDataSwift.showAlert("Failed!", andMsg: "Email has been failed.", andViewController: self)
            break
            
        }
    }
    
    //MARK: - HTTP Services
    
    func getAttendance() {
        
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        
        var requiredFromDateString = ""
        var fromDateString = ""
        
        var requiredToDateString = ""
        var toDateString = ""
        
        var type = "month"
        var attendanceFor = ""
        
        if self.viewSelectDates.isHidden {
            
            type = "month"
            attendanceFor = "for \(self.selectedMonthName) \(AppData.getDateWithFormateString("yyyy", andDateObject: Date())!)"
            
        }else{
            
            type = "date"
            
            fromDateString = "\(labelFromDate.text!)"
            let fromDateObj = AppData.getDateObjectFromString(withTime: fromDateString, andDateFormat: "dd/MM/yyyy")
            requiredFromDateString = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: fromDateObj)
            
            toDateString = "\(labelToDate.text!)"
            let toDateObj = AppData.getDateObjectFromString(withTime: toDateString, andDateFormat: "dd/MM/yyyy")
            requiredToDateString = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: toDateObj)
            
            attendanceFor = "from \(fromDateString) to \(toDateString)"
            
            print("fromDateString: \(fromDateString), requiredFromDateString: \(requiredFromDateString), toDateString: \(toDateString), requiredToDateString: \(requiredToDateString)," )
        }
        
        print("type: \(type), self.selectedMonth: \(self.selectedMonth), self.selectedMonthName: \(self.selectedMonthName), ")
        
        let url = AppDataSwift.BASE_URL + "getAttendance"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id,
            "date_from": requiredFromDateString,
            "date_to": requiredToDateString,
            "type": type,
            "month": self.selectedMonth
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("getAttendance JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    self.historyArray = json["data"]
                    self.tableView.reloadData()
                    self.calculateTotalTime(withDataArray: self.historyArray, andReportingObject: json["report_settings"])
                    
                    let username = "\(AppDataSwift.defaults.object(forKey: "name")!)"
                    AppDataSwift.generatePDF(username: username, total_duration: self.labelTotalHoursGiven.text!, dataArray: self.historyArray, attendanceFor: attendanceFor)
                    
//                    //save data
//                    AppDataSwift.defaults.set(self.labelFromDate.text!, forKey: "fromDate")
//                    AppDataSwift.defaults.set(self.labelToDate.text!, forKey: "toDate")
//                    AppDataSwift.defaults.set(NSKeyedArchiver.archivedData(withRootObject: json["data"].arrayObject!), forKey: "historyArray")
//                    AppDataSwift.defaults.synchronize()
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Error!", andMsg: message, andViewController: self)
                    
                }
                
            case .failure(let error):
                print("error: \(error)")
            }
            
            self.setInfoView()
            AppDataSwift.dismissLoader(viewController: self)
            
        })
        
    }
    
    
    func calculateTotalTime(withDataArray data: JSON, andReportingObject reportingObject: JSON) {
        
        var totalTimeInSeconds: Int = 0
        var totalTimeInMinuts: Int = 0
        var totalTimeInHours: Int = 0
        
        for i in 0 ..< data.count {
            
            let obj = data[i]
            
            let checkOut = obj["time_out"].string
            
            if checkOut != nil && checkOut != "" {
                
                let total_time_duration = data[i]["total_time_duration"].stringValue
                print("total_time_duration: \(total_time_duration)")
                
                let timeInHrs = Int(total_time_duration.substring(with: 0 ..< 2))
                let timeInMin = Int(total_time_duration.substring(with: 3 ..< 5))
                let timeInSec = Int(total_time_duration.substring(with: 6 ..< 8))
                print("timeInSec: \(timeInSec!), timeInMin: \(timeInMin!), timeInHrs: \(timeInHrs!), ")
                
                totalTimeInSeconds += timeInSec!
                totalTimeInMinuts += timeInMin!
                totalTimeInHours += timeInHrs!
                
            }
            
        }
        
        if totalTimeInSeconds > 59 {
            let min = Int(totalTimeInSeconds / 60)
            totalTimeInSeconds = Int(totalTimeInSeconds % 60)
            totalTimeInMinuts += min
        }
        
        if totalTimeInMinuts > 59 {
            let hrs = Int(totalTimeInMinuts / 60)
            totalTimeInMinuts = Int(totalTimeInMinuts % 60)
            totalTimeInHours += hrs
        }
        
        print("totalTimeInSeconds: \(totalTimeInSeconds), totalTimeInMinuts: \(totalTimeInMinuts), totalTimeInHours: \(totalTimeInHours)")
        
        let roundedTotalTimeInHours = round(Double(totalTimeInHours + (totalTimeInMinuts / 60)))
        self.labelTotalHoursGiven.text = String(format: "%.0f Hours", roundedTotalTimeInHours)
        
        //reporting
        //                    "report_settings": {
        //                        "job_hours": null,
        //                        "total_days": null
        //                    }
        
        print("sadfasf \(reportingObject["total_days"].stringValue)")
        
        if reportingObject["total_days"].stringValue != "" {
            
            let total_days: Int = reportingObject["total_days"].intValue
            let job_hours = reportingObject["job_hours"].intValue
            let totalRequiredHours = total_days * job_hours
            
            self.labelTotalHoursRequiredTitle.isHidden = false
            self.labelTotalHoursRequired.isHidden = false
            self.viewSeparator.isHidden = false
            self.labelTotalHoursRemainigTitle.isHidden = false
            self.labelTotalHoursRemainig.isHidden = false
            
            self.labelTotalHoursRequired.text = String(format: "%zd Hours", totalRequiredHours)

            var totalRemainigHours = Double(totalRequiredHours) - Double(roundedTotalTimeInHours)
            print("totalRemainigHours: \(totalRemainigHours)")
            
            if totalRemainigHours < 0 {
                self.labelTotalHoursRemainigTitle.text = "Total Additional Hours:"
                self.labelTotalHoursRemainigTitle.textColor = UIColor.init(red: 0/255, green: 152/255, blue: 37/255, alpha: 1)
                totalRemainigHours *= -1
            }else{
                self.labelTotalHoursRemainigTitle.text = "Total Remaining Hours:"
                self.labelTotalHoursRemainigTitle.textColor = UIColor.init(red: 225/255, green: 75/255, blue: 76/255, alpha: 1)
            }
            print("totalRemainigHours: \(totalRemainigHours)")
            
            self.labelTotalHoursRemainig.text = String(format: "%.0f Hours", round(totalRemainigHours))
            
        }else{
            
            self.labelTotalHoursRequiredTitle.isHidden = true
            self.labelTotalHoursRequired.isHidden = true
            self.viewSeparator.isHidden = true
            self.labelTotalHoursRemainigTitle.isHidden = true
            self.labelTotalHoursRemainig.isHidden = true
            
        }
        
    }
    
}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 80.0
        } else {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        let labelDate = cell.contentView.viewWithTag(1) as! UILabel
        let labelTime = cell.contentView.viewWithTag(2) as! UILabel
        let btnView = cell.contentView.viewWithTag(3) as! UIButton
        
        AppData.setBorderWith(btnView, andBorderWidth: 1.0, andBorderColor: .lightGray, andBorderRadius: btnView.frame.size.height / 2.0 )
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = .white
        }else{
            cell.contentView.backgroundColor = AppData.color(fromHexString: "#E5E5E5", andAlpha: 1.0)
        }
        
        let obj = self.historyArray[indexPath.row]
        
        //Date
        let date = obj["dateof"].stringValue
        let dateObj = AppData.getDateObjectFromString(withTime: date, andDateFormat: "yyyy-MM-dd")
        let requiredDateString = AppData.getDateWithFormateString("EEE, d MMM yyyy", andDateObject: dateObj)
        
        labelDate.text = requiredDateString!
        
        let checkOut = obj["time_out"].string
        
        //Time
        
        if checkOut != nil && checkOut != "" {
            
            let time = obj["total_time_duration"].stringValue
            let timeObj = AppData.getDateObjectFromString(withTime: time, andDateFormat: "HH:mm:ss", andTimeZone: TimeZone.init(abbreviation: "UTC"))
            let requiredTimeString = AppData.getDateWithFormateString("HH'h', mm'm', ss's'", andDateObject: timeObj, andTimeZone: TimeZone.init(abbreviation: "UTC"))
            
            labelTime.text = requiredTimeString!
            
        }else{
            
            labelTime.text = "-"
            
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HistoryPopUpViewController") as! HistoryPopUpViewController
        vc.dataObj = self.historyArray[indexPath.row]
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
}


extension HistoryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.isShowHistoryByPicker {
            return self.historyTypes.count
        }else{
            return self.months.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.isShowHistoryByPicker {
            return self.historyTypes[row]
        }else{
            return self.months[row]["title"]
        }
    }
}


extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

/*
 
 {
 "status": "Success",
 "code": 200,
 "msg": "14 Records Found",
 "data": [
 {
 "_id": "1753",
 "user_id": "15",
 "dateof": "2017-10-18",
 "time_in": "09:47:43",
 "time_out": null,
 "location": null,
 "type": "checking",
 "total_time": null,
 "break_time_in": "09:47:43",
 "break_time_out": null,
 "total_time_duration": "00:00:00"
 },
 {
 "_id": "1722",
 "user_id": "15",
 "dateof": "2017-10-16",
 "time_in": "10:25:53",
 "time_out": "18:59:36",
 "location": null,
 "type": "checking",
 "total_time": "30823",
 "break_time_in": "10:25:53",
 "break_time_out": "18:59:36",
 "total_time_duration": "08:33:43"
 },
 {
 "_id": "1690",
 "user_id": "15",
 "dateof": "2017-10-13",
 "time_in": "10:02:42",
 "time_out": "18:01:55",
 "location": null,
 "type": "checking",
 "total_time": "28753",
 "break_time_in": "10:02:42",
 "break_time_out": "18:01:55",
 "total_time_duration": "07:59:13"
 },
 {
 "_id": "1668",
 "user_id": "15",
 "dateof": "2017-10-12",
 "time_in": "09:36:24",
 "time_out": "17:16:44",
 "location": null,
 "type": "checking",
 "total_time": "27620",
 "break_time_in": "09:36:24",
 "break_time_out": "17:16:44",
 "total_time_duration": "07:40:20"
 },
 {
 "_id": "1646",
 "user_id": "15",
 "dateof": "2017-10-11",
 "time_in": "09:41:37",
 "time_out": "17:33:17",
 "location": null,
 "type": "checking",
 "total_time": "28300",
 "break_time_in": "09:41:37",
 "break_time_out": "17:33:17",
 "total_time_duration": "07:51:40"
 },
 {
 "_id": "1633",
 "user_id": "15",
 "dateof": "2017-10-10",
 "time_in": "10:26:19",
 "time_out": "19:00:13",
 "location": null,
 "type": "checking",
 "total_time": "30834",
 "break_time_in": "10:26:19",
 "break_time_out": "19:00:13",
 "total_time_duration": "08:33:54"
 },
 {
 "_id": "1634",
 "user_id": "15",
 "dateof": "2017-10-06",
 "time_in": "11:15:00",
 "time_out": "19:36:00",
 "location": null,
 "type": "checking",
 "total_time": "30060",
 "break_time_in": "11:15:00",
 "break_time_out": "19:36:00",
 "total_time_duration": "08:21:00"
 },
 {
 "_id": "1579",
 "user_id": "15",
 "dateof": "2017-10-05",
 "time_in": "09:25:57",
 "time_out": "18:10:46",
 "location": null,
 "type": "checking",
 "total_time": "31489",
 "break_time_in": "09:25:57",
 "break_time_out": "18:10:46",
 "total_time_duration": "08:44:49"
 },
 {
 "_id": "1563",
 "user_id": "15",
 "dateof": "2017-10-04",
 "time_in": "09:23:19",
 "time_out": "19:53:31",
 "location": null,
 "type": "checking",
 "total_time": "37812",
 "break_time_in": "09:23:19",
 "break_time_out": "19:53:31",
 "total_time_duration": "10:30:12"
 },
 {
 "_id": "1545",
 "user_id": "15",
 "dateof": "2017-10-03",
 "time_in": "09:57:49",
 "time_out": "16:39:25",
 "location": null,
 "type": "checking",
 "total_time": "24096",
 "break_time_in": "09:57:49",
 "break_time_out": "16:39:25",
 "total_time_duration": "06:41:36"
 },
 {
 "_id": "1536",
 "user_id": "15",
 "dateof": "2017-10-02",
 "time_in": "13:29:16",
 "time_out": "18:08:35",
 "location": null,
 "type": "checking",
 "total_time": "16759",
 "break_time_in": "13:29:16",
 "break_time_out": "18:08:35",
 "total_time_duration": "04:39:19"
 },
 {
 "_id": "1506",
 "user_id": "15",
 "dateof": "2017-09-29",
 "time_in": "09:50:24",
 "time_out": "21:24:29",
 "location": null,
 "type": "checking",
 "total_time": "41645",
 "break_time_in": "09:50:24",
 "break_time_out": "21:24:29",
 "total_time_duration": "11:34:05"
 },
 {
 "_id": "1479",
 "user_id": "15",
 "dateof": "2017-09-28",
 "time_in": "09:52:41",
 "time_out": "19:50:32",
 "location": null,
 "type": "checking",
 "total_time": "35871",
 "break_time_in": "09:52:41",
 "break_time_out": "19:50:32",
 "total_time_duration": "09:57:51"
 },
 {
 "_id": "1464",
 "user_id": "15",
 "dateof": "2017-09-27",
 "time_in": "09:59:16",
 "time_out": "23:12:41",
 "location": null,
 "type": "checking",
 "total_time": "47605",
 "break_time_in": "09:59:16",
 "break_time_out": "23:12:41",
 "total_time_duration": "13:13:25"
 }
 ],
 "report_settings": {
 "job_hours": null,
 "total_days": null
 }
 }
 
 */
