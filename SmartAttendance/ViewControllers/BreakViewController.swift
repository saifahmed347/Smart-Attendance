//
//  BreakViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 08/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class BreakViewController: UIViewController {
    
    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    
    var timer = Timer()
    var breakTimeInSeconds = 0
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelNote: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            
            let breakStartTime = AppDataSwift.defaults.integer(forKey: "breakStartTime")
            let currentTime = Int(CFAbsoluteTimeGetCurrent())
            print("breakStartTime: \(breakStartTime), currentTime: \(currentTime)")
            
            self.breakTimeInSeconds = currentTime - breakStartTime
            print("breakTimeInSeconds: \(breakTimeInSeconds)")
            
        }else{
            
            self.breakTimeInSeconds = 0
            let breakStartTime = Int(CFAbsoluteTimeGetCurrent())
            print("breakStartTime: \(breakStartTime)")
            AppDataSwift.defaults.set(true, forKey: "isBreakStarted")
            AppDataSwift.defaults.set(breakStartTime, forKey: "breakStartTime")
            AppDataSwift.defaults.synchronize()
            
        }
        
        //Attributed String
        let simpleString: String = "By clicking Resume you get back to working hours calculation from where you left!"
        
        let range = NSRange.init(location: 12, length: 6) // for Resume
        
        let attributedString = NSMutableAttributedString(string: simpleString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: AppData.color(fromHexString: "#FF4120", andAlpha: 1.0) , range: range)
        
        self.labelDescription.attributedText = attributedString
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
    
    @IBAction func btnTopLogoAction(_ sender: Any) {
        if !AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        }
    }
    
    @IBAction func btnEmployeeImageAction(_ sender: Any) {
        if !AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        }
    }
    
    //MARK: Tab Bar Buttons
    
    @IBAction func btnMenuAction(_ sender: Any) {
        if !AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        }
    }
    
    @IBAction func btnProfileAction(_ sender: Any) {
        if !AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        }
    }
    
    @IBAction func btnHistoryAction(_ sender: Any) {
        if !AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            AppDataSwift.gotoHistoryScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        }
    }
    
    @IBAction func btnAboutAction(_ sender: Any) {
        if !AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            AppDataSwift.gotoLeaveScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        }
    }
    
    
    //MARK: - Resume
    
    @IBAction func btnResumeAction(_ sender: Any) {
        
        AppDataSwift.defaults.set(false, forKey: "isBreakStarted")
        AppDataSwift.defaults.set(0, forKey: "breakStartTime")
        AppDataSwift.defaults.synchronize()
        self.timer.invalidate()
        print("self.breakTimeInSeconds: \(self.breakTimeInSeconds)")
        
        let userId = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        let imei = "\(UIDevice.current.identifierForVendor?.uuidString ?? "imei")"
        let location = "\(AppDataSwift.defaults.object(forKey: "latitude")!),\(AppDataSwift.defaults.object(forKey: "longitude")!)"
        
        let date = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: Date())
        let time = AppData.getDateWithFormateString("HH:mm:ss", andDateObject: Date())
        let type = "break"
        let attendanceFor = "time_out"
        
        if AppDataSwift.isWifiConnected {
            
            self.markAttendance(withUserId: userId, Type: type, andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andAttendanceFor: attendanceFor)
            
        }else{
            
            self.markAttendanceOffline(withUserId: userId, Type: type, andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andAttendanceFor: attendanceFor, andIsUploaded: "0")
            
        }
        
        
    }
    
    
    //MARK: - Timer
    
    @objc func updateTime() {
        
        self.breakTimeInSeconds += 1
        self.labelTime.text = self.convertSecondsToMinutes(withTimeInSeconds: self.breakTimeInSeconds)
    }
    
    
    func convertSecondsToMinutes(withTimeInSeconds value: Int) -> String {
        
        
        let hours = value / 3600
        let minutes = (value - (hours * 3600)) / 60
        let seconds = value % 60
        
        print("total time: \(value), hours: \(hours) minutes: \(minutes), seconds: \(seconds)")
        
        var timeString = ""
        
        
        if minutes < 10 && seconds < 10 {
            
            timeString = String(format: "0%zd:0%zd:0%zd", hours, minutes, seconds)
            
        } else if minutes < 10 && seconds > 9 {
            
            timeString = String(format: "0%zd:0%zd:%zd", hours, minutes, seconds)
            
        } else if minutes > 9 && seconds < 10 {
            
            timeString = String(format: "0%zd:%zd:0%zd", hours, minutes, seconds)
            
        } else if minutes > 9 && seconds > 9 {
            
            timeString = String(format: "0%zd:%zd:%zd", hours, minutes, seconds)
            
        }
        
        return timeString
    }
    
    
    //MARK: - HTTP Service
    
    func markAttendance(withUserId userId: String, Type type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andAttendanceFor attendanceFor: String) {
        
        print("type: \(type), location: \(location), date: \(date), attendanceFor: \(attendanceFor), time:\(time)")
        
        
        let url = AppDataSwift.BASE_URL + "markAttendance"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": userId,
            "type": type,
            "location": location,
            "device": "iphone",
            "imei": imei,
            "dateof": date,
            "attendance_for": attendanceFor,
            "timeof": time
            ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("markAttendance JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    //Save in database
                    self.markAttendanceOffline(withUserId: userId, Type: type, andLocation: location, andIMEI: imei, andDate: date, andTime: time, andAttendanceFor: attendanceFor, andIsUploaded: "1")
                    
                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Info!", andMsg: message, andViewController: self)
                    
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Info!", andMsg: message, andViewController: self)
                    
                }
                
            case .failure(let error):
                
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                
            }
            
            AppDataSwift.dismissLoader(viewController: self)
            
        })
        
    }
    
    
    func markAttendanceOffline(withUserId userId: String, Type type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andAttendanceFor attendanceFor: String, andIsUploaded isUploaded: String) {
        
        DBManager.getInstance().markAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: attendanceFor, andImageName: "", andIsUploaded: isUploaded)
        
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        AppDataSwift.showAlert("Info!", andMsg: "Your break ended.", andViewController: self)
    }
    
}
