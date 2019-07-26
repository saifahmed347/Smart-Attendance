//
//  ManualAttendanceViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/12/18.
//  Copyright © 2018 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ManualAttendanceViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    
    //Date Selection
    @IBOutlet weak var labelFromDate: UILabel!
    @IBOutlet weak var labelToDate: UILabel!
    @IBOutlet weak var labelAttendanceDate: UILabel!
    var isFromDateSelected = true
    
    //Date Picker
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!

    
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var textViewDescription: UITextView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    let textViewPlaceHolder = "Enter Note Here..."

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingBorders()
        }
        
        self.labelFromDate.text = "Time In"
        self.labelToDate.text = "Time Out"
        self.labelAttendanceDate.text = "Date"
        
        self.textViewDescription.text = textViewPlaceHolder
        self.textViewDescription.delegate = self  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
    }
    
    func settingBorders(){
        AppData.setBorderWith(self.viewDescription, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: 20.0)
        AppData.setBorderWith(self.btnSubmit, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: self.btnSubmit.frame.size.height / 2.0)
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
    
    
    
    //MARK: - Dates
    
    @IBAction func btnFromDateAction(_ sender: Any) {
        self.datePicker.datePickerMode = .time
        self.view.endEditing(true)
        self.isFromDateSelected = true
        self.datePicker.isHidden = false
        self.timePicker.isHidden = true
        self.viewDatePicker.isHidden = false
    }
    
    @IBAction func btnToDateAction(_ sender: Any) {
        self.datePicker.datePickerMode = .time
        self.view.endEditing(true)
        self.isFromDateSelected = false
        self.datePicker.isHidden = false
        self.timePicker.isHidden = true
        self.viewDatePicker.isHidden = false
    }
    
    @IBAction func btnAttDateAction(_ sender: Any) {
        self.timePicker.datePickerMode = .date
        self.view.endEditing(true)
//        self.isFromDateSelected = true
        self.datePicker.isHidden = true
        self.timePicker.isHidden = false
        self.viewDatePicker.isHidden = false
    }
    
    
    //MARK: - Date Picker
    
    @IBAction func btnDoneAction(_ sender: Any) {
        
        self.viewDatePicker.isHidden = true
        
        if !self.datePicker.isHidden {
            if self.isFromDateSelected {
                self.labelFromDate.text = AppData.getDateWithFormateString("hh:mm a", andDateObject: self.datePicker.date)
            } else {
                self.labelToDate.text = AppData.getDateWithFormateString("hh:mm a", andDateObject: self.datePicker.date)
            }
        }else{
           
            self.labelAttendanceDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: self.timePicker.date)
        }
        
    }
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.viewDatePicker.isHidden = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        
        if self.textViewDescription.text == textViewPlaceHolder {
            self.textViewDescription.text = ""
        }
        
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        
        if AppDataSwift.isWifiConnected {
             if self.textViewDescription.text == textViewPlaceHolder || self.textViewDescription.text == "" {
                AppDataSwift.shakeTextField(self.viewDescription)
            }else{
                AppDataSwift.showLoader("", andViewController: self)
//                self.employeeLeave(withReasonId: reasonId, andReason: "\(self.textViewDescription.text!)")
                self.manualAttendance(andReason: "\(self.textViewDescription.text!)")
            }
        }else{
            AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
        }
        
    }
    
    func manualAttendance(andReason reason: String) {
        
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        print("user_id: \(user_id), reason: \(reason)")
        
        let fromDateString = "\(labelFromDate.text!)"
        let fromDateObj = AppData.getDateObjectFromString(withTime: fromDateString, andDateFormat: "hh:mm a")
        let requiredFromDateString = AppData.getDateWithFormateString("hh:mm a", andDateObject: fromDateObj)
        
        let toDateString = "\(labelToDate.text!)"
        let toDateObj = AppData.getDateObjectFromString(withTime: toDateString, andDateFormat: "hh:mm a")
        let requiredToDateString = AppData.getDateWithFormateString("hh:mm a", andDateObject: toDateObj)
        
        let toAttDateString = "\(labelAttendanceDate.text!)"
        let toAttDateObj = AppData.getDateObjectFromString(withTime: toAttDateString, andDateFormat: "dd/MM/yyyy")
        let requiredToAttDateString = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: toAttDateObj)
        
        print("fromDateString: \(fromDateString), requiredFromDateString: \(requiredFromDateString!), toDateString: \(toDateString), requiredToDateString: \(requiredToDateString!), toAttDateString: \(toAttDateString), requiredToAttDateString: \(requiredToAttDateString!), ")
        
        let url = AppDataSwift.BASE_URL + "manualAttendance"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id,
            "time_in": requiredFromDateString!,
            "time_out": requiredToDateString!,
            "note": reason,
            "dateof": requiredToAttDateString!
        ]
        print("--- params : \(parameters)")
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("manualAttendance JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
//                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Success!", andMsg: message, andViewController: self)
                    self.labelAttendanceDate.text = "Date"
                    self.labelFromDate.text = "Time In"
                    self.labelToDate.text = "Time Out"
                    self.textViewDescription.text = self.textViewPlaceHolder
                    
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

}
