//
//  ManualAttendancePopUpViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/16/18.
//  Copyright © 2018 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

protocol ManualAttendancePopUpViewControllerDelegate {
    
    func dismissManualAttendancePopUpViewController()
    
}

class ManualAttendancePopUpViewController: UIViewController, LateCheckOutPopUpViewControllerDelegate, UITextViewDelegate {

    var delegate : ManualAttendancePopUpViewControllerDelegate? = nil
    
    @IBOutlet weak var viewDescription: UIView!
    
    var userID : String = ""
    var type : String = ""
    var location : String = ""
    var device : String = ""
    var imei : String = ""
    var attendanceFor : String = ""
    var employeeIMG = UIImage()
    var imageCheck : String = ""
    

    
    @IBOutlet weak var textViewNote: UITextView!
    let textViewPlaceHolder = "Enter Note Here..."
    
    @IBOutlet weak var btnCheckout: UIButton!
    @IBOutlet weak var btnNotNow: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        self.setKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingBorders()
        }
        
        self.textViewNote.text = textViewPlaceHolder
        self.textViewNote.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    func settingBorders(){
        AppData.setBorderWith(self.viewDescription, andBorderWidth: 1, andBorderColor: .black, andBorderRadius: 20.0)
        
        AppData.setBorderWith(self.btnCheckout, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: self.btnCheckout.frame.size.height / 2.0)
        
        AppData.setBorderWith(self.btnNotNow, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: self.btnNotNow.frame.size.height / 2.0)
    }
    
    
    // MARK: - Keyboard
    
    func setKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 110
                
//                self.textViewNote.text = ""
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
            
//            if self.textViewNote.text == ""{
//                self.textViewNote.text = ""
//            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        
        if self.textViewNote.text == textViewPlaceHolder {
            self.textViewNote.text = ""
        }
        
    }
    
    
    @IBAction func btnCheckOutAction(_ sender: Any) {
        
        let dateObj = Date()
        let date = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: dateObj)
        let time = AppData.getDateWithFormateString("HH:mm:ss", andDateObject: dateObj)
        
        if AppDataSwift.isWifiConnected {
           
            if self.textViewNote.text == textViewPlaceHolder || self.textViewNote.text == "" {
                AppDataSwift.shakeTextField(self.viewDescription)
            }
            else
            {
                AppDataSwift.showLoader("", andViewController: self)
                self.markAttendanceAfterTimeOut(withUserId: self.userID, withType: "checking", andLocation: self.location, andIMEI: self.imei, andOfDate: date!, andTime: time!, andAttendanceFor: self.attendanceFor, andDayEndNote: self.textViewNote.text!, andEmployeeImage: self.employeeIMG, andDateObj: dateObj)
               
            }
        }
        else
        {

            if self.textViewNote.text == textViewPlaceHolder || self.textViewNote.text == "" {
                AppDataSwift.shakeTextField(self.viewDescription)
            }
            else{
                
                self.markAttendanceForTimeOutOffline(withUserId: self.userID, withType: "checking", andLocation: self.location, andIMEI: self.imei, andDate: date!, andTime: time!, andEmployeeImage: self.employeeIMG, andDayEndNote: self.textViewNote.text!, andDateObj: dateObj, andIsUploaded: "0")
            }
        }
        
    }
    @IBAction func btnNotNowAction(_ sender: Any) {
        
        if self.delegate != nil{
            
            self.delegate?.dismissManualAttendancePopUpViewController()
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    //MARK: - HTTP Service
    
    func markAttendanceAfterTimeOut(withUserId userId: String, withType type: String, andLocation location: String, andIMEI imei: String, andOfDate ofdate: String, andTime time: String, andAttendanceFor attendanceFor: String, andDayEndNote dayendnote: String ,andEmployeeImage empImage: UIImage, andDateObj dateObj: Date) {
        
        print("type: \(type), location: \(location), date: \(ofdate), attendanceFor: \(attendanceFor)")
        
        let url = AppDataSwift.BASE_URL + "markAttendance"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": userId,
            "type": type,
            "location": location,
            "device": "iphone",
            "imei": imei,
            "dateof": ofdate,
            "timeof": time,
            "attendance_for": attendanceFor,
            "day_ended_note": dayendnote,
            "day_ended": "true",
            ]
        
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                let imageData: Data = AppData.compressImage(AppData.resizeImageAccordingToWidth(with: empImage, scaledToWidth: 200.0))
                
                multipartFormData.append(imageData, withName: "employee_img", fileName: "employee_img.jpg", mimeType: "image/jpeg")
                
                for (key, value) in parameters {
                    let v = value as! String
                    print("v: \(v)")
                    
                    multipartFormData.append(v.data(using: .utf8)!, withName: key)
                }
                
        },
            to: url, headers: AppDataSwift.getHTTPHeader(),
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        switch response.result {
                            
                        case .success(let value):
                            
                            let json = JSON(value)
                            print("Manual Attendance After Time Out JSON: \(json)")
                            
                            if json["status"].stringValue == "Success" {
                                
                             print("successss")
                                self.markAttendanceForTimeOutOffline(withUserId: userId, withType: "checking", andLocation: location, andIMEI: imei, andDate: ofdate, andTime: time, andEmployeeImage: empImage, andDayEndNote: dayendnote, andDateObj: dateObj, andIsUploaded: "1")
                                
                                
                            } else if json["status"].stringValue.localizedLowercase == "error" {

                                let message = json["msg"].stringValue
                                
                                print("--- this is info message : \(message)")
                                
                                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                                    
                                    AppDataSwift.showAlert("Info!", andMsg: message, andViewController: self)
                                
                            }
                            
                        case .failure(let error):
                            
                            AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                            AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                            
                        }
                        
                        AppDataSwift.dismissLoader(viewController: self)
                        
                    }
                    
                case .failure(let encodingError):
                    
                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    AppDataSwift.showAlert("Error!", andMsg: encodingError.localizedDescription, andViewController: self)
                    
                }
                
        })
        
    }
    
    func markAttendanceForTimeOutOffline(withUserId userId: String, withType type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andEmployeeImage empImage: UIImage, andDayEndNote dayendnote: String, andDateObj dateObj: Date, andIsUploaded isUploaded: String) {
        
        //Offline
        let imageName = AppDataSwift.getImageName(withUserId: userId, andDate: dateObj)
        
        if AppDataSwift.defaults.bool(forKey: "isOpenScannerForCheckIn") {
            
            if !DBManager.getInstance().isAlreadyCheckin(withUserId: userId, andDateOf: date, andType: "checking") {
                
//                DBManager.getInstance().markAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_in", andImageName: imageName, andIsUploaded: isUploaded)
                
//                DBManager.getInstance().time(WithUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_in", andImageName: imageName, andDayEndedNote: dayendnote, andDayEnded: true, andIsUploaded: isUploaded)
                
                DBManager.getInstance().timeOutMarkAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_in", andImageName: imageName, andDayEndedNote: dayendnote, andDayEnded: true, andIsUploaded: isUploaded)
                
                if isUploaded == "0" {
                    AppDataSwift.saveImageInDocumentDirectory(withImage: empImage, andImageName: imageName)
                    DBManager.getInstance().insertImageRecord(withUserId: userId, andImageName: imageName, andIsUploaded: isUploaded)
                }
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LateCheckOutPopUpViewController") as! LateCheckOutPopUpViewController
                vc.delegate = self
                vc.empImage = AppData.resizeImageAccordingToWidth(with: self.employeeIMG, scaledToWidth: 200.0)
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                
                print("is open from scanner donnneee")

                
            }else{
                
                AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                AppDataSwift.showAlert("Info!", andMsg: "You already have checked in for your attendance today.", andViewController: self)
                
            }
            
        }else{
            
            if DBManager.getInstance().isAlreadyCheckin(withUserId: userId, andDateOf: date, andType: "checking") && !DBManager.getInstance().isAlreadyCheckOut(withUserId: userId, andDateOf: date, andType: "checking") {
                
//                DBManager.getInstance().markAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_out", andImageName: imageName, andIsUploaded: isUploaded)\
                
                DBManager.getInstance().timeOutMarkAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_out", andImageName: imageName, andDayEndedNote: dayendnote, andDayEnded: true, andIsUploaded: isUploaded)
                
                if isUploaded == "0" {
                    AppDataSwift.saveImageInDocumentDirectory(withImage: empImage, andImageName: imageName)
                    DBManager.getInstance().insertImageRecord(withUserId: userId, andImageName: imageName, andIsUploaded: isUploaded)
                    
                }
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LateCheckOutPopUpViewController") as! LateCheckOutPopUpViewController
                vc.delegate = self
                vc.empImage = AppData.resizeImageAccordingToWidth(with: self.employeeIMG, scaledToWidth: 200.0)
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                
                print("donnneee")
                
            }else{
                
                AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                AppDataSwift.showAlert("Info!", andMsg: "You already have checked out for your attendance today.", andViewController: self)
                
            }
            
        }
        
        
    }
    
    func dismissLateCheckOutPopUpViewController() {
                AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
}
