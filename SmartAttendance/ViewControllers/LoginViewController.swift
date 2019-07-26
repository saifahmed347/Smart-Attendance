//
//  LoginViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 07/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var imageViewLogo: UIImageView!
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnLoginWithTouch: UIButton!
    
    //Slider
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    
    var yPositionSlider: CGFloat = 0.0
    var bottomSpace: CGFloat = 0.0
    
    var alertController = UIAlertController()
    
    //Contact Form
    @IBOutlet weak var viewContactName: UIView!
    @IBOutlet weak var viewContactPhoneNumber: UIView!
    @IBOutlet weak var viewContactEmail: UIView!
    @IBOutlet weak var viewContactMessage: UIView!
    
    @IBOutlet weak var tfContactName: UITextField!
    @IBOutlet weak var tfContactPhoneNumber: UITextField!
    @IBOutlet weak var tfContactEmail: UITextField!
    @IBOutlet weak var tvContactMessage: UITextView!
    @IBOutlet weak var btnContactSubmit: UIButton!
    
    var tvContactMessagePlaceHolder = "Write message here..."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setKeyboard()
        
//        self.tfEmail.text = "001296" //"014212" //"003134" //"001503" //"002164"
//        self.tfPassword.text = "gexton"
        
        if (AppDataSwift.defaults.object(forKey: "employeeIdForField") != nil) {
            self.tfEmail.text = "\(AppDataSwift.defaults.object(forKey: "employeeIdForField")!)"
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        self.setBorders()
        self.settingFonts()
        self.settingSliderViewValues()
    }
    
 
    func setBorders() {
        
        let borderRaius = self.tfEmail.frame.size.height / 2.0
        
        AppData.setBorderWith(self.tfEmail, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRaius)
        
        AppData.setBorderWith(self.tfPassword, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRaius)
        
        AppData.setBorderWith(self.btnLogin, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRaius)
        
        AppData.setBorderWith(self.btnLoginWithTouch, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRaius)
        
    }
    
    func settingFonts(){
        
        //        name: ["Ubuntu", "Ubuntu-Medium", "Ubuntu-Light", "Ubuntu-MediumItalic", "Ubuntu-BoldItalic", "Ubuntu-LightItalic", "Ubuntu-Italic", "Ubuntu-Bold"]
        
        var ubuntoRegularFont: UIFont = UIFont.init(name: "Ubuntu", size: 15.0)!
        var nexaBoldFont: UIFont = UIFont.init(name: "Ubuntu-Medium", size: 15.0)!
        
        if AppData.isIphone6() {
            ubuntoRegularFont = UIFont.init(name: "Ubuntu", size: 16.0)!
            nexaBoldFont = UIFont.init(name: "Ubuntu-Medium", size: 16.0)!
        } else if AppData.isIphone6P() {
            ubuntoRegularFont = UIFont.init(name: "Ubuntu", size: 17.0)!
            nexaBoldFont = UIFont.init(name: "Ubuntu-Medium", size: 17.0)!
        }
        
        self.tfEmail.font = ubuntoRegularFont
        self.tfPassword.font = ubuntoRegularFont
        
        self.btnLogin.titleLabel?.font = nexaBoldFont
        self.btnLoginWithTouch.titleLabel?.font = nexaBoldFont
    
    }
    
    func doLogin() {
        
        if !self.tfEmail.hasText {
            
            AppDataSwift.shakeTextField(self.tfEmail)
            
        }else if !self.tfPassword.hasText {
            
            AppDataSwift.shakeTextField(self.tfPassword)
            
        }else{
            
            if AppDataSwift.isWifiConnected {
                
                AppDataSwift.defaults.set("\(self.tfEmail.text!)", forKey: "employeeIdForField")
                AppDataSwift.defaults.synchronize()
                
                AppDataSwift.showLoader("", andViewController: self)
                self.login(withUsername: self.tfEmail.text!, andPassword: self.tfPassword.text!)
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
            
        }
    }
    
    @IBAction func btnLoginAction(_ sender: Any) {
        
        self.doLogin()
        
    }
    
    
    // MARK: - Textfields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTage = textField.tag + 1;
        
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.viewWithTag(nextTage) as UIResponder?
        
        if (nextResponder != nil){
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
            
        } else {
            
            self.doLogin()
            
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    
    // MARK: - Keyboard
    
    func setKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

 
    //MARK: - Forgot Password
    
    @IBAction func btnForgotPasswordAction(_ sender: Any) {
        
        alertController = UIAlertController(title: "Forgot password?", message: "Please enter your email address to reset your password.", preferredStyle: .alert)
        
        self.alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email Address"
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            
            let tf = self.alertController.textFields![0] as UITextField
            
            if tf.hasText {

                if AppDataSwift.isWifiConnected {
                    AppDataSwift.showLoader("", andViewController: self)
                    self.forgetPassword(withEmail: tf.text!)
                }else{
                    AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.alertController.dismiss(animated: true, completion: nil)
        })
        
        
        self.alertController.addAction(okAction)
        self.alertController.addAction(cancelAction)
        
        self.present(self.alertController, animated: true, completion: nil)

        
    }
    
    
    
    // MARK: - HTTP Services
    
    
    func login(withUsername username: String, andPassword password: String) {
        
        print("username: \(username), password: \(password)")
        
        let url = AppDataSwift.BASE_URL + "login"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "username": username,
            "password": password
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("login JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                
                    if json["data"].exists() {
                       
                        self.saveData(data: json["data"], username: username)
                        
                    }else{
                        
                        AppDataSwift.showAlert("Server Error!", andMsg: "User data object not exists in server response.", andViewController: self)
                        
                    }
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {

                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Error!", andMsg: message, andViewController: self)
                    
                }
                
            case .failure(let error):
                
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                
            }
            
            AppDataSwift.dismissLoader(viewController: self)
            
        })
        
    }
    
    
    func saveData(data: JSON, username: String){
        
        AppDataSwift.defaults.set(true, forKey: "isLogin")
        AppDataSwift.defaults.set(data["_id"].stringValue, forKey: "user_id")
        AppDataSwift.defaults.set(username, forKey: "employee_id")
        AppDataSwift.defaults.set(data["company_id"].stringValue, forKey: "company_id")
        AppDataSwift.defaults.set(data["company_name"].stringValue, forKey: "company_name")
        AppDataSwift.defaults.set(data["name"].stringValue, forKey: "name")
        AppDataSwift.defaults.set(data["username"].stringValue, forKey: "username")
        AppDataSwift.defaults.set(data["email"].stringValue, forKey: "email")
        AppDataSwift.defaults.set(data["profile_pic"].stringValue, forKey: "profile_pic")
        AppDataSwift.defaults.set(data["profile_pic"].stringValue, forKey: "profile_pic")
        AppDataSwift.defaults.set(data["status"].stringValue, forKey: "status")
        AppDataSwift.defaults.set(data["skype"].stringValue, forKey: "skype")
        AppDataSwift.defaults.set(data["overview"].stringValue, forKey: "overview")
        AppDataSwift.defaults.set(data["contact"].stringValue, forKey: "contact")
        AppDataSwift.defaults.set(data["departement_name"].stringValue, forKey: "departement_name")
        AppDataSwift.defaults.set(data["about_company"].stringValue, forKey: "about_company")
        AppDataSwift.defaults.set(data["company_latitude"].doubleValue, forKey: "company_latitude")
        AppDataSwift.defaults.set(data["company_longitude"].doubleValue, forKey: "company_longitude")
        AppDataSwift.defaults.set(data["location_radius"].doubleValue, forKey: "location_radius")
        AppDataSwift.defaults.synchronize()
        
        let attendance = data["attendance"]
        if attendance.count > 0 {
            for i in 0 ..< attendance.count {
                let obj = attendance[i]
                    DBManager.getInstance().insertRecord(withUserId: obj["user_id"].string, andType: obj["type"].string, andLocation: obj["location"].string, andLocationCheckIn: obj["location_checkin"].string, andLocationOut: obj["location_checkout"].string, andDevice: obj["device"].string, andIMEI: obj["imei"].string, andDateOf: obj["dateof"].string, andTimeIn: obj["time_in"].string, andTimeOut: obj["time_out"].string, andTimeDifference: obj["time_diff"].string, andCreateTime: obj["created_time"].string, andUpdateTime: obj["updated_time"].string, andCheckInImage: obj["check_in_image"].string, andCheckOutImage: obj["check_out_image"].string, andIsUploaded: "1")
            }
        }
        
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
        
    }
    
    
    func forgetPassword(withEmail email: String) {
        
        print("email: \(email)")
        
        let url = AppDataSwift.BASE_URL + "forgotPassword"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "email": email
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("forgetPassword JSON: \(json)")
                
                self.alertController.dismiss(animated: true, completion: nil)
                
                if json["status"].stringValue.localizedLowercase == "success" {
                
                    AppDataSwift.showAlert("Success!", andMsg: json["msg"].stringValue, andViewController: self)
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                
                    AppDataSwift.showAlert("Error!", andMsg: json["msg"].stringValue, andViewController: self)
                    
                }
                
            case .failure(let error):
                
                self.alertController.dismiss(animated: true, completion: nil)
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                
            }
            
            AppDataSwift.dismissLoader(viewController: self)
        })
        
    }

    //MARK: - Slider
    
    
    @IBOutlet weak var btnSliderUp: UIButton!
    
    @IBAction func btnSliderUpAction(_ sender: Any) {
        if self.mainView.frame.origin.y == self.yPositionSlider {
            //move up slider
            self.bounsAnimation(self.yPositionSlider - (self.mainViewHeight.constant / 2.0))
        } else {
            //move down slider
            self.bounsAnimation(self.yPositionSlider)
        }
    }
    
    func settingSliderViewValues(){
        
        AppData.setBorderWith(self.mainView, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: 3)
        self.yPositionSlider = self.mainView.frame.origin.y
        self.bottomSpace = self.mainViewBottomConstraint.constant
        
        AppData.setBorderWith(self.btnContactSubmit, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: self.btnContactSubmit.frame.size.height/2)
        
        //form views border
        AppData.setBorderWith(self.viewContactName, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: 3)
        AppData.setBorderWith(self.viewContactPhoneNumber, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: 3)
        AppData.setBorderWith(self.viewContactEmail, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: 3)
        AppData.setBorderWith(self.viewContactMessage, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: 3)
        self.tvContactMessage.textColor = UIColor.lightGray
        self.tvContactMessage.text = self.tvContactMessagePlaceHolder
        
    }
    
    @IBAction func draggingSlideView(_ sender: Any) {
    
        let gestureRecognizer = sender as? UIPanGestureRecognizer
        let translation = gestureRecognizer?.translation(in: self.mainView)
        
        if gestureRecognizer?.state == .began || gestureRecognizer?.state == .changed {
            let value = (gestureRecognizer?.view?.frame.origin.y)! + (translation?.y)!
            print("value: \(value)")
            
            if value > 0 {
                gestureRecognizer?.view?.frame.origin.y = value
                gestureRecognizer?.setTranslation(CGPoint.zero, in: self.mainView)
                self.backGroundView.alpha -= ((translation?.y)! / 100.0)
            }
            
        } else {
            self.bounsAnimation((gestureRecognizer?.view?.frame.origin.y)!)
        }
    }
    
    
    func bounsAnimation(_ currentYPosition: CGFloat)  {
        
        print("currentYPosition: \(currentYPosition), self.yPositionSlider - self.mainViewHeight.constant/2: \(self.yPositionSlider - self.mainViewHeight.constant/2)")
        
        print("self.bottomSpaceddd: \(self.bottomSpace)")
        
        if currentYPosition <= (self.yPositionSlider - (self.mainViewHeight.constant / 2.0)) {
            //Move up
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: {
                self.mainView.frame.origin.y = self.yPositionSlider + self.bottomSpace
                self.backGroundView.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.mainViewBottomConstraint.constant = 0.0
                    self.btnSliderUp.setImage(UIImage.init(named: "arrow_down"), for: .normal)
                }, completion: nil)
            })
        } else {
            //Move down
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: {
                self.mainView.frame.origin.y = self.yPositionSlider
                self.backGroundView.alpha = 0.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.mainViewBottomConstraint.constant = self.bottomSpace
                    self.btnSliderUp.setImage(UIImage.init(named: "arrow_up"), for: .normal)
                }, completion: nil)
            })
        }
    }
    
    @IBAction func btnContactSubmitAction(_ sender: Any) {
        self.view.endEditing(true)
        if !self.tfContactName.hasText {
            AppDataSwift.shakeTextField(self.tfContactName)
        }else if !self.tfContactPhoneNumber.hasText {
            AppDataSwift.shakeTextField(self.tfContactPhoneNumber)
        }else if !self.tvContactMessage.hasText || self.tvContactMessage.text! == self.tvContactMessagePlaceHolder {
            AppDataSwift.shakeTextField(self.tvContactMessage)
        }else{
            if AppDataSwift.isWifiConnected {
                AppDataSwift.showLoader("", andViewController: self)
                self.sendInquiry(withName: self.tfContactName.text!, andPhone: self.tfContactPhoneNumber.text!, andEmail: self.tfContactEmail.text!, andMessage: self.tvContactMessage.text!)
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
        }
    }
    
    
    func sendInquiry(withName name: String, andPhone phone: String, andEmail email: String, andMessage msg: String) {
        
        print("name: \(name), phone: \(phone), email: \(email), msg: \(msg)")
        
        let url = AppDataSwift.BASE_URL + "sendInquiry"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "name": name,
            "phone": phone,
            "email": email,
            "message": msg
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("login JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    self.tfContactName.text = ""
                    self.tfContactPhoneNumber.text = ""
                    self.tfContactEmail.text = ""
                    self.tvContactMessage.text = self.tvContactMessagePlaceHolder
                    self.tvContactMessage.textColor = .lightText
                    
                    let message = json["msg"].stringValue
                    
                    let alertController = UIAlertController.init(title: "Thank You!", message: message, preferredStyle: UIAlertController.Style.alert)
                    let  alertActionOK = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        self.btnSliderUpAction(self)
                    })
                    alertController.addAction(alertActionOK)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Error!", andMsg: message, andViewController: self)
                    
                }
                
            case .failure(let error):
                
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                
            }
            
            AppDataSwift.dismissLoader(viewController: self)
            
        })
        
    }
    
    
    //MARK: - Login with touch id
    
    @IBAction func btnLoginWithTouchAction(_ sender: Any) {
        
        if AppDataSwift.defaults.bool(forKey: "isLoginWithFigerPrint") {
            self.authenticateUser()
        } else {
            AppDataSwift.showAlert("Warning!", andMsg: "Login with touch is not enabled. Please login with your username and password.", andViewController: self)
        }

        
    }
    
    
    func authenticateUser() {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] success, authenticationError in
                
                DispatchQueue.main.async {

                    if success {
                        
                        AppDataSwift.defaults.set(true, forKey: "isLogin")
                        AppDataSwift.defaults.synchronize()
                        
                        if AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
                            AppDataSwift.gotoBreakScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
                        }else{
                            AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
                        }
                        
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}


extension LoginViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.tvContactMessage.text! == self.tvContactMessagePlaceHolder {
            self.tvContactMessage.text = ""
            self.tvContactMessage.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if !self.tvContactMessage.hasText {
            self.tvContactMessage.text = self.tvContactMessagePlaceHolder
            self.tvContactMessage.textColor = UIColor.lightGray
        }
    }
}


/*
 
empty attandence
 ---------------
 
 {
 "status" : "Success",
 "code" : 200,
 "msg" : "Successfully Logged In.",
 "data" : {
 "signup_from" : "direct",
 "overview" : "My name is Dummy User and I work in Android Developer departement",
 "attendance" : "",
 "departement_name" : "Android Developer",
 "name" : "Dummy User",
 "skype" : "ggexton",
 "_id" : "22",
 "email" : "Ryal@test.com",
 "created_on" : "2017-06-12 23:57:51",
 "device_token" : "8559",
 "about_company" : "<strong>GEXTON<\/strong>, a solutions-focused company, was established in 2000. The company is registered in Pakistan and is 100% EOU (Export Oriented Unit). <br\/> <br\/> We provide complete business solutions, which enables businesses to leverage leading edge technology to gain sustainable competitive advantages in today’s marketplace. We are known for our talent, passion, work ethic and building ongoing long term relationships and commitment through support and maintenance.<br\/> <br\/> Currently, the Development Centre of GEXTON is located in the calm and serene vicinity of GZP, close to the Indus River in the City of Cold wind, Hyderabad, Pakistan. A good team is significant to the success of any business.<br\/> <br\/> <strong>GEXTON<\/strong> takes pride in having a trustworthy and sturdy team of more than 15 members.",
 "profile_pic" : "http:\/\/demii.com\/smart_attendance\/uploads\/employees\/2017\/06\/1497329871_diaujnima.jpg",
 "username" : "003001",
 "desc" : "",
 "usertype" : "employee",
 "company_id" : "3",
 "contact" : "03453561895",
 "forgot_password_token" : "",
 "platform" : "ios",
 "is_login" : "1",
 "status" : "active",
 "token_exp" : "",
 "company_name" : "Dummy Company"
 }
 }
 
 
 only checking
 -------------
 
 {
 "status" : "Success",
 "code" : 200,
 "msg" : "Successfully Logged In.",
 "data" : {
 "signup_from" : "direct",
 "overview" : "My name is Dummy User and I work in Android Developer departement",
 "attendance" : {
 "time_diff" : "",
 "user_ip" : "110.38.134.228",
 "location_checkout" : "",
 "updated_time" : "",
 "location" : "",
 "device" : "iphone",
 "type" : "checking",
 "_id" : "329",
 "dateof" : "2017-07-19",
 "imei" : "9E4EDA82-D93C-4CB7-A260-1",
 "location_checkin" : "25.3755255971139,68.34933208408879",
 "user_agent" : "SmartAttendance\/3.0 (com.gexton.SmartAttendance; build:3; iOS 10.2.0) Alamofire\/4.4.0",
 "time_out" : "",
 "user_id" : "22",
 "check_out_image" : "",
 "sync_data" : "0",
 "check_in_image" : "2017\/07\/1500468480_employee_img.jpg",
 "created_time" : "2017-07-19 07:48:00",
 "time_in" : "17:48:00"
 },
 "departement_name" : "Android Developer",
 "name" : "Dummy User",
 "skype" : "ggexton",
 "_id" : "22",
 "email" : "Ryal@test.com",
 "created_on" : "2017-06-12 23:57:51",
 "device_token" : "",
 "about_company" : "<strong>GEXTON<\/strong>, a solutions-focused company, was established in 2000. The company is registered in Pakistan and is 100% EOU (Export Oriented Unit). <br\/> <br\/> We provide complete business solutions, which enables businesses to leverage leading edge technology to gain sustainable competitive advantages in today’s marketplace. We are known for our talent, passion, work ethic and building ongoing long term relationships and commitment through support and maintenance.<br\/> <br\/> Currently, the Development Centre of GEXTON is located in the calm and serene vicinity of GZP, close to the Indus River in the City of Cold wind, Hyderabad, Pakistan. A good team is significant to the success of any business.<br\/> <br\/> <strong>GEXTON<\/strong> takes pride in having a trustworthy and sturdy team of more than 15 members.",
 "profile_pic" : "http:\/\/demii.com\/smart_attendance\/uploads\/employees\/2017\/06\/1497329871_diaujnima.jpg",
 "username" : "003001",
 "desc" : "",
 "usertype" : "employee",
 "company_id" : "3",
 "contact" : "03453561895",
 "forgot_password_token" : "",
 "platform" : "ios",
 "is_login" : "0",
 "status" : "active",
 "token_exp" : "",
 "company_name" : "Dummy Company"
 }
 }

 
 breaking
 --------
 
 {
 "status" : "Success",
 "code" : 200,
 "msg" : "Successfully Logged In.",
 "data" : {
 "signup_from" : "direct",
 "overview" : "My name is Dummy User and I work in Android Developer departement",
 "attendance" : [
 {
 "time_diff" : null,
 "user_ip" : "110.38.134.228",
 "location_checkout" : null,
 "updated_time" : null,
 "location" : null,
 "device" : "iphone",
 "type" : "checking",
 "_id" : "329",
 "dateof" : "2017-07-19",
 "imei" : "9E4EDA82-D93C-4CB7-A260-1",
 "location_checkin" : "25.3755255971139,68.34933208408879",
 "user_agent" : "SmartAttendance\/3.0 (com.gexton.SmartAttendance; build:3; iOS 10.2.0) Alamofire\/4.4.0",
 "time_out" : null,
 "user_id" : "22",
 "check_out_image" : "",
 "sync_data" : "0",
 "check_in_image" : "2017\/07\/1500468480_employee_img.jpg",
 "created_time" : "2017-07-19 07:48:00",
 "time_in" : "17:48:00"
 },
 {
 "time_diff" : "00:00:06",
 "user_ip" : "110.38.134.228",
 "location_checkout" : null,
 "updated_time" : "2017-07-19 17:49:03",
 "location" : null,
 "device" : "iphone",
 "type" : "break",
 "_id" : "330",
 "dateof" : "2017-07-19",
 "imei" : "9E4EDA82-D93C-4CB7-A260-1",
 "location_checkin" : "25.37552622337658,68.34932252833154",
 "user_agent" : "SmartAttendance\/3.0 (com.gexton.SmartAttendance; build:3; iOS 10.2.0) Alamofire\/4.4.0",
 "time_out" : "17:49:03",
 "user_id" : "22",
 "check_out_image" : "",
 "sync_data" : "0",
 "check_in_image" : "",
 "created_time" : "2017-07-19 07:48:57",
 "time_in" : "17:48:57"
 }
 ],
 "departement_name" : "Android Developer",
 "name" : "Dummy User",
 "skype" : "ggexton",
 "_id" : "22",
 "email" : "Ryal@test.com",
 "created_on" : "2017-06-12 23:57:51",
 "device_token" : "",
 "about_company" : "<strong>GEXTON<\/strong>, a solutions-focused company, was established in 2000. The company is registered in Pakistan and is 100% EOU (Export Oriented Unit). <br\/> <br\/> We provide complete business solutions, which enables businesses to leverage leading edge technology to gain sustainable competitive advantages in today’s marketplace. We are known for our talent, passion, work ethic and building ongoing long term relationships and commitment through support and maintenance.<br\/> <br\/> Currently, the Development Centre of GEXTON is located in the calm and serene vicinity of GZP, close to the Indus River in the City of Cold wind, Hyderabad, Pakistan. A good team is significant to the success of any business.<br\/> <br\/> <strong>GEXTON<\/strong> takes pride in having a trustworthy and sturdy team of more than 15 members.",
 "profile_pic" : "http:\/\/demii.com\/smart_attendance\/uploads\/employees\/2017\/06\/1497329871_diaujnima.jpg",
 "username" : "003001",
 "desc" : "",
 "usertype" : "employee",
 "company_id" : "3",
 "contact" : "03453561895",
 "forgot_password_token" : "",
 "platform" : "ios",
 "is_login" : "0",
 "status" : "active",
 "token_exp" : "",
 "company_name" : "Dummy Company"
 }
 }
 
 
 checking with checkout
 -----------------------
 
 {
 "status" : "Success",
 "code" : 200,
 "msg" : "Successfully Logged In.",
 "data" : {
 "signup_from" : "direct",
 "overview" : "My name is Dummy User and I work in Android Developer departement",
 "attendance" : [
 {
 "time_diff" : "00:15:27",
 "user_ip" : "110.38.134.228",
 "location_checkout" : null,
 "updated_time" : "2017-07-19 18:03:27",
 "location" : null,
 "device" : "iphone",
 "type" : "checking",
 "_id" : "329",
 "dateof" : "2017-07-19",
 "imei" : "9E4EDA82-D93C-4CB7-A260-1",
 "location_checkin" : "25.3755255971139,68.34933208408879",
 "user_agent" : "SmartAttendance\/3.0 (com.gexton.SmartAttendance; build:3; iOS 10.2.0) Alamofire\/4.4.0",
 "time_out" : "18:03:27",
 "user_id" : "22",
 "check_out_image" : "2017\/07\/1500469407_employee_img.jpg",
 "sync_data" : "0",
 "check_in_image" : "2017\/07\/1500468480_employee_img.jpg",
 "created_time" : "2017-07-19 07:48:00",
 "time_in" : "17:48:00"
 },
 {
 "time_diff" : "00:00:06",
 "user_ip" : "110.38.134.228",
 "location_checkout" : null,
 "updated_time" : "2017-07-19 17:49:03",
 "location" : null,
 "device" : "iphone",
 "type" : "break",
 "_id" : "330",
 "dateof" : "2017-07-19",
 "imei" : "9E4EDA82-D93C-4CB7-A260-1",
 "location_checkin" : "25.37552622337658,68.34932252833154",
 "user_agent" : "SmartAttendance\/3.0 (com.gexton.SmartAttendance; build:3; iOS 10.2.0) Alamofire\/4.4.0",
 "time_out" : "17:49:03",
 "user_id" : "22",
 "check_out_image" : "",
 "sync_data" : "0",
 "check_in_image" : "",
 "created_time" : "2017-07-19 07:48:57",
 "time_in" : "17:48:57"
 }
 ],
 "departement_name" : "Android Developer",
 "name" : "Dummy User",
 "skype" : "ggexton",
 "_id" : "22",
 "email" : "Ryal@test.com",
 "created_on" : "2017-06-12 23:57:51",
 "device_token" : "8559",
 "about_company" : "<strong>GEXTON<\/strong>, a solutions-focused company, was established in 2000. The company is registered in Pakistan and is 100% EOU (Export Oriented Unit). <br\/> <br\/> We provide complete business solutions, which enables businesses to leverage leading edge technology to gain sustainable competitive advantages in today’s marketplace. We are known for our talent, passion, work ethic and building ongoing long term relationships and commitment through support and maintenance.<br\/> <br\/> Currently, the Development Centre of GEXTON is located in the calm and serene vicinity of GZP, close to the Indus River in the City of Cold wind, Hyderabad, Pakistan. A good team is significant to the success of any business.<br\/> <br\/> <strong>GEXTON<\/strong> takes pride in having a trustworthy and sturdy team of more than 15 members.",
 "location_radius" : "100",
 "profile_pic" : "http:\/\/demii.com\/smart_attendance\/uploads\/employees\/2017\/06\/1497329871_diaujnima.jpg",
 "username" : "003001",
 "desc" : "",
 "usertype" : "employee",
 "company_id" : "3",
 "contact" : "03453561895",
 "forgot_password_token" : "",
 "platform" : "ios",
 "is_login" : "1",
 "status" : "active",
 "token_exp" : "",
 "company_name" : "Dummy Company"
 }
 }
 
 
 */

