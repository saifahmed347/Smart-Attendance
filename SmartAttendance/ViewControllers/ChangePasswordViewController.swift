//
//  ChangePasswordViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePasswordViewController: UIViewController {

    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var tfCurrentPassword: UITextField!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    @IBOutlet weak var labelError: UILabel!
    
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setBorders()
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setBorders(){
        
        let borderRadius = self.tfCurrentPassword.frame.size.height / 2.0
    
        AppData.setBorderWith(self.tfCurrentPassword, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRadius)
        AppData.setBorderWith(self.tfNewPassword, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRadius)
        AppData.setBorderWith(self.tfConfirmPassword, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRadius)
        AppData.setBorderWith(self.btnSubmit, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRadius)
        AppData.setBorderWith(self.btnCancel, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: borderRadius)
        
        AppData.setBorderWith(self.mainView, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: 20.0)
        
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
            
            self.changePassword()
            
        }
        
        return false // We do not want UITextField to insert line-breaks.
    }

    
    func changePassword() {
        
        self.labelError.isHidden = true
        
        if !self.tfCurrentPassword.hasText {
            AppDataSwift.shakeTextField(self.tfCurrentPassword)
        } else if !self.tfNewPassword.hasText {
            AppDataSwift.shakeTextField(self.tfNewPassword)
        } else if !self.tfConfirmPassword.hasText {
            AppDataSwift.shakeTextField(self.tfConfirmPassword)
        } else if self.tfNewPassword.text! != self.tfConfirmPassword.text! {
            self.labelError.isHidden = false
            AppDataSwift.shakeTextField(self.tfNewPassword)
            AppDataSwift.shakeTextField(self.tfConfirmPassword)
            self.labelError.text = "Passwords not matched!"
        } else {
            if AppDataSwift.isWifiConnected {
                AppDataSwift.showLoader("", andViewController: self)
                self.changePassword(withNewPassword: self.tfNewPassword.text!, andOldPassword: self.tfCurrentPassword.text!)
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
        }
        
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        self.changePassword()
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    //MARK: - HTTP Services
    
    func changePassword(withNewPassword new_password: String, andOldPassword old_password: String) {
        
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        
        let url = AppDataSwift.BASE_URL + "changePassword"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id,
            "new_password": new_password,
            "old_password": old_password
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("changePassword JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    let ac = UIAlertController.init(title: "Success!", message: "Your password is changed successfully!", preferredStyle: .alert)
                    let ok = UIAlertAction.init(title: "OK", style: .default, handler: { action in
                        self.dismiss(animated: true, completion: nil)
                    })
                    ac.addAction(ok)
                    self.present(ac, animated: true, completion: nil)
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    
                    let message = json["message"].stringValue
                    AppDataSwift.showAlert("Error!", andMsg: message, andViewController: self)
                    
                }
                
            case .failure(let error):
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
            }
            
            AppDataSwift.dismissLoader(viewController: self)
            
        })
        
    }
    

    
}
