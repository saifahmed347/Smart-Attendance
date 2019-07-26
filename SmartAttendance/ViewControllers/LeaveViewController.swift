//
//  LeaveViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 23/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class LeaveViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    
    //Date Selection
    @IBOutlet weak var labelFromDate: UILabel!
    @IBOutlet weak var labelToDate: UILabel!
    var isFromDateSelected = true
    
    //Date Picker
    @IBOutlet weak var viewDatePicker: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //Subject Picker
    @IBOutlet weak var subjectPicker: UIPickerView!
    
    var subjectArray: JSON = JSON.null
    
    
    @IBOutlet weak var viewSubject: UIView!
    @IBOutlet weak var labelSubject: UILabel!
    
    @IBOutlet weak var viewDescription: UIView!
    @IBOutlet weak var textViewDescription: UITextView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    let textViewPlaceHolder = "Write here..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.settingBorders()
        }
        
        self.labelFromDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: Date())
        self.labelToDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: Date())
        
        self.textViewDescription.text = textViewPlaceHolder
        self.textViewDescription.delegate = self
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (AppDataSwift.defaults.object(forKey: "subjectArray") != nil) {
            
            let data = NSKeyedUnarchiver.unarchiveObject(with: AppDataSwift.defaults.object(forKey: "subjectArray") as! Data)
            self.subjectArray = JSON(data!)
            self.subjectPicker.reloadAllComponents()
            
            print("subjectArray: \(self.subjectArray)")
            self.getLeaveSubjects()
            
        }else{
            
            if AppDataSwift.isWifiConnected {
                AppDataSwift.showLoader("", andViewController: self)
                self.getLeaveSubjects()
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
    }
    
    func settingBorders(){
        AppData.setBorderWith(self.viewSubject, andBorderWidth: 1, andBorderColor: .clear, andBorderRadius: self.viewSubject.frame.size.height / 2.0)
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
        self.view.endEditing(true)
        self.isFromDateSelected = true
        self.datePicker.isHidden = false
        self.subjectPicker.isHidden = true
        self.viewDatePicker.isHidden = false
    }
    
    @IBAction func btnToDateAction(_ sender: Any) {
        self.view.endEditing(true)
        self.isFromDateSelected = false
        self.datePicker.isHidden = false
        self.subjectPicker.isHidden = true
        self.viewDatePicker.isHidden = false
    }
    
    
    //MARK: - Date Picker
    
    @IBAction func btnDoneAction(_ sender: Any) {
        
        self.viewDatePicker.isHidden = true
        
        if !self.datePicker.isHidden {
            if self.isFromDateSelected {
                self.labelFromDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: self.datePicker.date)
            } else {
                self.labelToDate.text = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: self.datePicker.date)
            }
        }else{
            self.labelSubject.text = self.subjectArray[self.subjectPicker.selectedRow(inComponent: 0)]["reason"].stringValue
        }
        
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.viewDatePicker.isHidden = true
    }
    
    
    //MARK: - Subject picker
    
    @IBAction func btnSelectSubjectAction(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDatePicker.isHidden = false
        self.datePicker.isHidden = true
        self.subjectPicker.isHidden = false
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        
        if self.textViewDescription.text == textViewPlaceHolder {
            self.textViewDescription.text = ""
        }
        
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        
        if AppDataSwift.isWifiConnected {
            if self.labelSubject.text == "Select Subject" {
                AppDataSwift.shakeTextField(self.viewSubject)
            } else if self.textViewDescription.text == textViewPlaceHolder || self.textViewDescription.text == "" {
                AppDataSwift.shakeTextField(self.viewDescription)
            }else{
                let reasonId = self.subjectArray[self.subjectPicker.selectedRow(inComponent: 0)]["_id"].stringValue
                AppDataSwift.showLoader("", andViewController: self)
                self.employeeLeave(withReasonId: reasonId, andReason: "\(self.textViewDescription.text!)")
            }
        }else{
            AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
        }
        
    }
    
    
    //MARK: - HTTP Services
    
    func getLeaveSubjects(){
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        
        let url = AppDataSwift.BASE_URL + "getLeaveSubjects?user_id=\(user_id)"
        
        print("url: \(url)")
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("getLeaveSubjects JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    self.subjectArray = json["data"]
                    self.subjectPicker.reloadAllComponents()
                    
                    //save data
                    AppDataSwift.defaults.set(self.labelFromDate.text!, forKey: "fromDate")
                    AppDataSwift.defaults.set(self.labelToDate.text!, forKey: "toDate")
                    AppDataSwift.defaults.set(NSKeyedArchiver.archivedData(withRootObject: json["data"].arrayObject!), forKey: "subjectArray")
                    AppDataSwift.defaults.synchronize()
                    
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
    
    
    func employeeLeave(withReasonId reasonId: String, andReason reason: String) {
        
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        print("user_id: \(user_id), reasonId: \(reasonId), reason: \(reason)")
        
        let fromDateString = "\(labelFromDate.text!)"
        let fromDateObj = AppData.getDateObjectFromString(withTime: fromDateString, andDateFormat: "dd/MM/yyyy")
        let requiredFromDateString = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: fromDateObj)
        
        let toDateString = "\(labelToDate.text!)"
        let toDateObj = AppData.getDateObjectFromString(withTime: toDateString, andDateFormat: "dd/MM/yyyy")
        let requiredToDateString = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: toDateObj)
        
        print("fromDateString: \(fromDateString), requiredFromDateString: \(requiredFromDateString!), toDateString: \(toDateString), requiredToDateString: \(requiredToDateString!), ")
        
        let url = AppDataSwift.BASE_URL + "employeeLeave"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id,
            "reason_id": reasonId,
            "date_from": requiredFromDateString!,
            "date_to": requiredToDateString!,
            "leave_reason": reason
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("employeeLeave JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Success!", andMsg: message, andViewController: self)
                    
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


extension LeaveViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.subjectArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.subjectArray[row]["reason"].stringValue
    }
    
}


