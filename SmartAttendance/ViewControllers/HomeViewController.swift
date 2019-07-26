//
//  HomeViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 07/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MediaPlayer
import MobileCoreServices
import CoreLocation
import SDWebImage

class HomeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    
    @IBOutlet weak var labelHi: UILabel!
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelAM: UILabel!
    
    @IBOutlet weak var btnAboutBottom: UIButton!
    
    var timer = Timer()
    
    var isUserTryToCheckIn = true
    
    //Checkin and checkout times
    
    @IBOutlet weak var viewCheckIn: UIView!
    @IBOutlet weak var labelCheckInTitle: UILabel!
    @IBOutlet weak var labelCheckInTime: UILabel!
    @IBOutlet weak var labelCheckInAM: UILabel!
    
    @IBOutlet weak var viewCheckOut: UIView!
    @IBOutlet weak var labelCheckOutTitle: UILabel!
    @IBOutlet weak var labelCheckOutTime: UILabel!
    @IBOutlet weak var labelCheckOutAM: UILabel!
    
    var checkedInTime = "-"
    var checkedOutTime = "-"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
        
        self.checkUpdate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.labelDate.text = AppData.getDateWithFormateString("EEEE, d MMM yyyy", andDateObject: Date())
        
        self.labelTime.text = AppData.getDateWithFormateString("hh:mm", andDateObject: Date())
        
        self.labelAM.text = AppData.getDateWithFormateString("a", andDateObject: Date())

        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        let date = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: Date())
        
        self.checkedInTime = DBManager.getInstance().getCheckingTime(withUserId: user_id, andDateOf: date, andType: "checking", andInOrOut: "time_in")
        
        
        self.checkedOutTime = DBManager.getInstance().getCheckingTime(withUserId: user_id, andDateOf: date, andType: "checking", andInOrOut: "time_out")
        print("checkedInTime: \(self.checkedInTime), checkedOutTime: \(self.checkedOutTime)")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
    }
    
    @objc func updateTime() {
        
        self.labelTime.text = AppData.getDateWithFormateString("hh:mm", andDateObject: Date())
        self.labelAM.text = AppData.getDateWithFormateString("a", andDateObject: Date())
        
        self.setCheckInAndCheckOutTime()
        
    }
    
    func setCheckInAndCheckOutTime(){
        
        if self.checkedInTime != "-" {
            
            self.labelCheckInAM.isHidden = false
            self.labelCheckOutAM.isHidden = false
            
            let checkedInTimeObj = AppData.getDateObjectFromString(withTime: self.checkedInTime, andDateFormat: "yyyy-MM-dd HH:mm:ss")
            
            self.labelCheckInTime.text = AppData.getDateWithFormateString("hh:mm", andDateObject: checkedInTimeObj)
            self.labelCheckInAM.text = AppData.getDateWithFormateString("a", andDateObject: checkedInTimeObj)
            
            if self.checkedOutTime != "-" {
                
                self.labelCheckOutTitle.text = "Check-Out"
                
                let checkedOutTimeObj = AppData.getDateObjectFromString(withTime: self.checkedOutTime, andDateFormat: "yyyy-MM-dd HH:mm:ss")
                
                self.labelCheckOutTime.text = AppData.getDateWithFormateString("hh:mm", andDateObject: checkedOutTimeObj)
                self.labelCheckOutAM.text = AppData.getDateWithFormateString("a", andDateObject: checkedOutTimeObj)
                
            }else{
                
                self.labelCheckOutTitle.text = "Duration"
            
                let workingHourInSeconds = Int(Date().timeIntervalSince(checkedInTimeObj!))
                
                let hours = workingHourInSeconds / 3600
                let minutes = (workingHourInSeconds - (hours * 3600)) / 60
                let seconds = workingHourInSeconds % 60
                
                var timeString = "00:00"
                
                if hours < 10 && minutes < 10 {
                    timeString = String(format: "0%zd:0%zd", hours, minutes)
                } else if hours < 10 && minutes > 9 {
                    timeString = String(format: "0%zd:%zd", hours, minutes)
                } else if hours > 9 && minutes < 10 {
                    timeString = String(format: "%zd:0%zd", hours, minutes)
                } else if hours > 9 && minutes > 9 {
                    timeString = String(format: "%zd:%zd", hours, minutes)
                }
                self.labelCheckOutTime.text = timeString
                
                if seconds < 10 {
                    self.labelCheckOutAM.text = String(format: "0%zd", seconds)
                }else{
                    self.labelCheckOutAM.text = String(format: "%zd", seconds)
                }
                
            }
            
        }else{

            self.labelCheckInTime.text = "-"
            self.labelCheckInAM.isHidden = true
            
            self.labelCheckOutTitle.text = "Check-Out"
            self.labelCheckOutTime.text = "-"
            self.labelCheckOutAM.isHidden = true
        }
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
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnEmployeeImageAction(_ sender: Any) {
        AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    //MARK: Tab Bar Buttons
    
    @IBAction func btnMenuAction(_ sender: Any) {
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnProfileAction(_ sender: Any) {
        AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnHistoryAction(_ sender: Any) {
        AppDataSwift.gotoHistoryScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnAboutAction(_ sender: Any) {
        AppDataSwift.gotoLeaveScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    
    //MARK: - Menus
    
    @IBAction func btnCheckInAction(_ sender: Any) {
        self.isUserTryToCheckIn = true
        self.doCheckIn()
    }
    
    func doCheckIn(){
        if self.checkLocationAuthentication() {
            if self.checkEmployeeInRadius() {
                AppDataSwift.defaults.set(true, forKey: "isOpenScannerForCheckIn")
                AppDataSwift.defaults.synchronize()
                AppDataSwift.gotoScannerScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
            }
        }
    }
    
    @IBAction func btnCheckOutAction(_ sender: Any) {
        self.isUserTryToCheckIn = false
        self.doCheckOut()
    }
    
    func doCheckOut(){
        if self.checkLocationAuthentication() {
            if self.checkEmployeeInRadius() {
                AppDataSwift.defaults.set(false, forKey: "isOpenScannerForCheckIn")
                AppDataSwift.defaults.synchronize()
                AppDataSwift.gotoScannerScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
            }
        }
    }
    
    @IBAction func btnBreakAction(_ sender: Any) {
        
        if AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
            
            AppDataSwift.gotoBreakScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
            
        }else{
            
            let alertController = UIAlertController.init(title: "Break!", message: "Are you sure you want to break?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction.init(title: "Yes", style: .default, handler: { action in
                
                let userId = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
                let imei = "\(UIDevice.current.identifierForVendor?.uuidString ?? "imei")"
                let location = "\(AppDataSwift.defaults.object(forKey: "latitude")!),\(AppDataSwift.defaults.object(forKey: "longitude")!)"
                
                let dateObj = Date()
                let date = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: dateObj)
                let time = AppData.getDateWithFormateString("HH:mm:ss", andDateObject: dateObj)
                
                let type = "break"
                let attendanceFor = "time_in"
                
                if AppDataSwift.isWifiConnected {
                    
                    AppDataSwift.showLoader("", andViewController: self)
                    self.markAttendance(withUserId: userId, withType: type, andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andAttendanceFor: attendanceFor)
                    
                }else{
                    
                    self.markAttendanceOffline(withUserId: userId, withType: type, andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andAttendanceFor: attendanceFor, andIsUploaded: "0")
                    
                }
                
            })
            
            let noAction = UIAlertAction.init(title: "No", style: .cancel, handler: { action in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func btnApplyLeaveAction(_ sender: Any) {
        AppDataSwift.gotoApplyLeaveScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    @IBAction func btnAboutBottomAction(_ sender: Any) {
        
//        let userId = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
//        let dataArray = DBManager.getInstance().getAllAttendanceOfEmployee(withUserId: userId)
//        print("dataArray: \(dataArray!)")
        
        AppDataSwift.gotoAboutUsScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
        
    }
    @IBAction func btnNotificationBottomAction(_ sender: Any) {
    
        AppDataSwift.gotoNotificationScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    
    }
    
    //MARK: - HTTP Service
    
    func markAttendance(withUserId userId: String, withType type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andAttendanceFor attendanceFor: String) {
        
        print("type: \(type), location: \(location), date: \(date), attendanceFor: \(attendanceFor)")
        
        let url = AppDataSwift.BASE_URL + "markAttendance"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": userId,
            "type": type,
            "location": location,
            "device": "iphone",
            "imei": imei,
            "dateof": date,
            "timeof": time,
            "attendance_for": attendanceFor,
            ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("markAttendance JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    DBManager.getInstance().markAttendance(withUserId: userId, andType: "break", andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: attendanceFor, andImageName: "", andIsUploaded: "1")
                    AppDataSwift.gotoBreakScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    
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
    
    
    func markAttendanceOffline(withUserId userId: String, withType type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andAttendanceFor attendanceFor: String, andIsUploaded isUploaded: String) {
        
        if !DBManager.getInstance().isAlreadyCheckin(withUserId: userId, andDateOf: date, andType: "checking") || DBManager.getInstance().isAlreadyCheckOut(withUserId: userId, andDateOf: date, andType: "checking") {
            
            AppDataSwift.showAlert("Info!", andMsg: "You can't get break because \(date)'s attendance has not been marked or completed already.", andViewController: self)
            
        }else{
            
            DBManager.getInstance().markAttendance(withUserId: userId, andType: "break", andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: attendanceFor, andImageName: "", andIsUploaded: isUploaded)
            AppDataSwift.gotoBreakScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
            
        }
    }
    
    
    //MARK: - Video uploading testing
    
    
    func startMediaBrowser() -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.videoMaximumDuration = TimeInterval(Int.max)
        mediaUI.videoQuality = .typeHigh
        mediaUI.delegate = self
        
        self.present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        print("mediaType: \(mediaType)")
        
        dismiss(animated: true) {
            if mediaType == kUTTypeMovie {
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                print("videoURL: \(videoURL.path)")
                
                //                do {
                //                    let videoFileData = try Data.init(contentsOf: videoURL)
                //                    print("size: \(videoFileData)")
                //                    self.uploadVideo(withVideoData: videoFileData, andURL: videoURL)
                //                }
                //                catch {/* error handling here */}
                
                AppDataSwift.showLoader("", andViewController: self)
                self.uploadVideo(withVideoData: Data(), andURL: videoURL)
                
            }
        }
    }
    
    
    func uploadVideo(withVideoData videoData: Data, andURL videoUrl: URL) {
        
        let url = AppDataSwift.BASE_URL + "uploadVideo"
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(videoUrl, withName: "video", fileName: "video.mov", mimeType: "video/mov")
                //                multipartFormData.append(videoData, withName: "video", fileName: "video.mov", mimeType: "video/mov")
                
        },
            to: url, headers: AppDataSwift.getHTTPHeader(),
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .success(let value):
                            
                            let json = JSON(value)
                            print("saveProfile JSON: \(json)")
                            
                            
                        case .failure(let error):
                            
                            AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                            
                        }
                        
                        AppDataSwift.dismissLoader(viewController: self)
                        
                    }
                    
                case .failure(let encodingError):
                    
                    AppDataSwift.showAlert("Error!", andMsg: encodingError.localizedDescription, andViewController: self)
                    
                }
                
        })
        
    }
    
    
    // MARK: - Location Mangaer
    
    func checkLocationAuthentication() -> Bool {
        
        var isAuthenticate = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                isAuthenticate = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.gotoSettings("Location Access Denied!", "Allow 'Smart Attendance' to access your current location so that we can find where are you. To allow access your location to 'Smart Attendance' go to Settings > Smart Attendance > Location than click on 'While Using the App'.")
                }
            case .authorizedAlways, .authorizedWhenInUse:
                isAuthenticate = true
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
            
        } else {
            isAuthenticate = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.gotoSettings("Location Service Disabled!", "Location Service is not enabled. To enable it go to Settings > Privacy > Location Services than enable it.")
            }
        }
        
        return isAuthenticate
    }
    
    
    func gotoSettings(_ title: String, _ msg: String){
        
        let alertController = UIAlertController (title: title, message: msg, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = Double((manager.location?.coordinate.latitude)!)
        let longitude = Double((manager.location?.coordinate.longitude)!)
        
        print("Home: latitude: \(latitude), longitude: \(longitude)")
        
        AppDataSwift.defaults.set(latitude, forKey: "latitude")
        AppDataSwift.defaults.set(longitude, forKey: "longitude")
        AppDataSwift.defaults.synchronize()
        
    }
    
    
    func checkEmployeeInRadius() -> Bool {
    
        let company_latitude = AppDataSwift.defaults.double(forKey: "company_latitude")
        let company_longitude = AppDataSwift.defaults.double(forKey: "company_longitude")
        let location_radius = AppDataSwift.defaults.double(forKey: "location_radius")
        
        let employee_latitude = AppDataSwift.defaults.double(forKey: "latitude")
        let employee_longitude = AppDataSwift.defaults.double(forKey: "longitude")
        
        print("company_latitude: \(company_latitude), company_longitude: \(company_longitude), location_radius: \(location_radius), employee_latitude: \(employee_latitude), employee_longitude: \(employee_longitude)")
        
        let company_location = CLLocation.init(latitude: company_latitude, longitude: company_longitude)
        let employee_location = CLLocation.init(latitude: employee_latitude, longitude: employee_longitude)
        
        let distanceInMeters = employee_location.distance(from: company_location) as CLLocationDistance
        print("distanceInMeters: \(distanceInMeters)")

        if distanceInMeters <= location_radius {
            return true
        }else{
            let msg = "You are not in \(AppDataSwift.defaults.object(forKey: "location_radius")!) meters of \(AppDataSwift.defaults.object(forKey: "company_name")!)'s location"
            
            let alertController = UIAlertController.init(title: "Location Error!", message: msg, preferredStyle: .alert)
            
            let tryAgainAction = UIAlertAction.init(title: "Try Again", style: .default, handler: { _ in
                if self.isUserTryToCheckIn {
                    self.doCheckIn()
                }else{
                    self.doCheckOut()
                }
            })
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
            
            alertController.addAction(tryAgainAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
    }
    
    
    //MARK: - Check Update
    func checkUpdate(){
        
        if AppDataSwift.defaults.object(forKey: "app_version") != nil {
            
            var notShowVersion = "0"
            
            if AppDataSwift.defaults.object(forKey: "notShowVersion") != nil {
                notShowVersion = "\(AppDataSwift.defaults.object(forKey: "notShowVersion")!)"
            }
                
            let app_version = "\(AppDataSwift.defaults.object(forKey: "app_version")!)"
            
            print("server_version: \(app_version), app_version: \(AppDataSwift.APP_VERSION), notShowVersion: \(notShowVersion)")
            
            if app_version != AppDataSwift.APP_VERSION && app_version != notShowVersion {
                
                let updateAppObject = JSON(AppDataSwift.defaults.dictionary(forKey: "updateAppObject")!)
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateAppViewController") as! UpdateAppViewController
                vc.dataObject = updateAppObject
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
}
