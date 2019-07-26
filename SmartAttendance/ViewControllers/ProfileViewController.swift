//
//  ProfileViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 07/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import LocalAuthentication
import MobileCoreServices

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var app_user_default = AppDataSwift()

    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDesignation: UILabel!
    
    @IBOutlet weak var labelContactInfo: UILabel!
    
    @IBOutlet weak var labelEmpIdTitle: UILabel!
    @IBOutlet weak var labelEmpId: UILabel!
    
    @IBOutlet weak var labelCompanyTitle: UILabel!
    @IBOutlet weak var labelCompany: UILabel!
    
    @IBOutlet weak var labelEmailTitle: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    @IBOutlet weak var labelSkypeTitle: UILabel!
    @IBOutlet weak var labelSkype: UILabel!
    
    @IBOutlet weak var labelMobileTitle: UILabel!
    @IBOutlet weak var labelMobile: UILabel!
    
    
    @IBOutlet weak var labelSecurity: UILabel!
    @IBOutlet weak var labelChangePassword: UILabel!
    @IBOutlet weak var labelFingerPrint: UILabel!
    
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var switchForLock: UISwitch!
    
    @IBOutlet weak var btnLogout: UIButton!
    
    var imagePicker = UIImagePickerController()
    var chosenImage = UIImage.init(named: "profile_orange_navigation_ipad")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.settingValues()

        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
        self.settingFonts()
        self.settingBorders()
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
    
    //MARK: - Photo
    
    @IBAction func btnEmployeeImageAction(_ sender: Any) {
        AppDataSwift.gotoProfileScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    
    @IBAction func btnProfileImageUploadAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Select Option:", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction!) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                AppDataSwift.showAlert("No Camera!", andMsg: "Your device doesn't have camera", andViewController: self)
            }
            
        })
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default, handler: { (action:UIAlertAction!) -> Void in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if (self.chosenImage?.isPortrait())! {
            self.imageViewProfilePic.image = self.chosenImage?.scaled(toHeight: self.imageViewProfilePic.frame.size.height * 2)
        }else{
            self.imageViewProfilePic.image = self.chosenImage?.scaled(toWidth: self.imageViewProfilePic.frame.size.width * 2)
        }
        
        picker.dismiss(animated:true, completion: nil)
        
        if AppDataSwift.isWifiConnected {
            let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
            AppDataSwift.showLoader("", andViewController: self)
            self.updateProfileImage(withUserId: user_id, Image: self.chosenImage!)
        }else{
            AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
        }
    }

    
    func settingBorders(){
    
        AppData.setBorderWith(self.imageViewProfilePic, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: self.imageViewProfilePic.frame.size.height / 2.0 )
        
        AppData.setBorderWith(self.btnLogout, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: self.btnLogout.frame.size.height / 2.0 )
    
        AppData.setBorderWith(self.btnChange, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: self.btnChange.frame.size.height / 2.0 )
    }
    
    
    func settingValues() {
        
        if AppDataSwift.defaults.bool(forKey: "isLoginWithFigerPrint") {
            self.switchForLock.setOn(true, animated: true)
        }else{
            self.switchForLock.setOn(false, animated: true)
        }

        let name = "\(AppDataSwift.defaults.object(forKey: "name")!)"
        let employee_id = "\(AppDataSwift.defaults.object(forKey: "employee_id")!)"
        let company_name = "\(AppDataSwift.defaults.object(forKey: "company_name")!)"
        let departement_name = "\(AppDataSwift.defaults.object(forKey: "departement_name")!)"
        let email = "\(AppDataSwift.defaults.object(forKey: "email")!)"
        let profile_pic = "\(AppDataSwift.defaults.object(forKey: "profile_pic")!)"
        let skype = "\(AppDataSwift.defaults.object(forKey: "skype")!)"
        let contact = "\(AppDataSwift.defaults.object(forKey: "contact")!)"
        
        self.labelName.text = name
        self.labelDesignation.text = departement_name
        self.labelEmpId.text = employee_id
        self.labelCompany.text = company_name
        self.labelEmail.text = email
        self.labelMobile.text = contact
        self.labelSkype.text = skype
        
        let placeHolderImage = AppData.imageSnapshot(fromText: name, backgroundColor: AppData.color(fromHexString: "#F96612", andAlpha: 1.0), foreGroundColor: .white, circular: true, textAttributes: nil, andImageView: self.imageViewProfilePic)
        
        if profile_pic != "" {
            let url = URL.init(string: profile_pic)
            let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
                if let image = image {
                    if image.isPortrait() {
                        self.imageViewProfilePic.image = image.scaled(toHeight: self.imageViewProfilePic.frame.size.height * 2)
                    }else{
                        self.imageViewProfilePic.image = image.scaled(toWidth: self.imageViewProfilePic.frame.size.width * 2)
                    }
                }
            }
            self.imageViewProfilePic.sd_setImage(with: url, completed: block)
        }else{
            self.imageViewProfilePic.image = placeHolderImage
        }
        
    }
    
    func settingFonts(){
        
//        name: ["Ubuntu", "Ubuntu-Medium", "Ubuntu-Light", "Ubuntu-MediumItalic", "Ubuntu-BoldItalic", "Ubuntu-LightItalic", "Ubuntu-Italic", "Ubuntu-Bold"]
        
        var ubuntoRegularFont: UIFont = UIFont.init(name: "Ubuntu", size: 10.0)!
        var ubuntoMediumFont: UIFont = UIFont.init(name: "Ubuntu-Medium", size: 10.0)!
        var ubuntoBoldFont: UIFont = UIFont.init(name: "Ubuntu-Bold", size: 11.0)!

        
        if AppData.isIphone6() {
        
            self.labelName.font = UIFont.init(name: "Ubuntu-Medium", size: 25.0)!
            ubuntoRegularFont = UIFont.init(name: "Ubuntu", size: 15.0)!
            ubuntoMediumFont = UIFont.init(name: "Ubuntu-Medium", size: 15.0)!
            ubuntoBoldFont = UIFont.init(name: "Ubuntu-Bold", size: 16.0)!
            
        } else if AppData.isIphone6P() {
        
            self.labelName.font = UIFont.init(name: "Ubuntu-Medium", size: 26.0)!
            ubuntoRegularFont = UIFont.init(name: "Ubuntu", size: 16.0)!
            ubuntoMediumFont = UIFont.init(name: "Ubuntu-Medium", size: 16.0)!
            ubuntoBoldFont = UIFont.init(name: "Ubuntu-Bold", size: 17.0)!
            
        }
        
        self.labelDesignation.font = ubuntoRegularFont
        
        self.labelContactInfo.font = ubuntoBoldFont
        self.labelSecurity.font = ubuntoBoldFont
        
        self.labelEmpIdTitle.font = ubuntoMediumFont
        self.labelCompanyTitle.font = ubuntoMediumFont
        self.labelEmailTitle.font = ubuntoMediumFont
        self.labelSkypeTitle.font = ubuntoMediumFont
        self.labelMobileTitle.font = ubuntoMediumFont
        
        self.labelEmpId.font = ubuntoRegularFont
        self.labelCompany.font = ubuntoRegularFont
        self.labelEmail.font = ubuntoRegularFont
        self.labelSkype.font = ubuntoRegularFont
        self.labelMobile.font = ubuntoRegularFont
        
        self.labelChangePassword.font = ubuntoMediumFont
        self.labelFingerPrint.font = ubuntoMediumFont
        
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

    
    @IBAction func btnLogoutAction(_ sender: Any) {

        let alertController = UIAlertController.init(title: "Logout!", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction.init(title: "Yes", style: .default, handler: { action in
            
            if AppDataSwift.isWifiConnected {
                
                AppDataSwift.showLoader("", andViewController: self)
                self.logout()
                
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
            
            
        })
        
        let noAction = UIAlertAction.init(title: "No", style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)

        
    }
    
    
    //MARK: - Security
    
    @IBAction func btnChagnePasswordAction(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)

    }
    
    
    @IBAction func switchForLockValueChanged(_ sender: Any) {

        if self.switchForLock.isOn {
            self.authenticateUser()
        } else {
            UserDefaults.standard.set(false, forKey: "isLoginWithFigerPrint")
            UserDefaults.standard.synchronize()
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
                        AppDataSwift.defaults.set(true, forKey: "isLoginWithFigerPrint")
                        AppDataSwift.defaults.synchronize()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "Sorry!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            self.switchForLock.setOn(false, animated: true)
            self.switchForLock.isOn = false
            let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    //MARK: - HTTP Services
    func logout() {
        
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        
        let url = AppDataSwift.BASE_URL + "logout"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("logout JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    DBManager.getInstance().deleteAllData()
                    
                    AppDataSwift.defaults.removeObject(forKey: "leavesArray")
                    AppDataSwift.defaults.removeObject(forKey: "historyArray")
                    AppDataSwift.defaults.removeObject(forKey: "isBreakStarted")
                    AppDataSwift.defaults.removeObject(forKey: "breakStartTime")
                    AppDataSwift.defaults.removeObject(forKey: "isLoginWithFigerPrint")
                    AppDataSwift.defaults.set(false, forKey: "isLogin")
                    self.app_user_default.userdefault?.removeObject(forKey: "push-notification")
                    self.app_user_default.userdefault?.synchronize()
                    
                    AppDataSwift.defaults.synchronize()
                    
                    AppDataSwift.gotoLoginScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    
                    let message = json["message"].stringValue
                    AppDataSwift.showAlert("Error!", andMsg: message, andViewController: self)
                    
                }
                
            case .failure(let error):
                
                AppDataSwift.dismissLoader(viewController: self)
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                
            }
            
        })
        
    }


    func updateProfileImage(withUserId userId: String, Image image: UIImage) {
        
        print("userId: \(userId)")
        
        let url = AppDataSwift.BASE_URL + "update_profile_image"
        print("updatecoverpic url: \(url)")
        
        let parameters: Parameters = [
            "user_id" : userId
        ]
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                let imageData: Data = image.compressedData()!
                
                multipartFormData.append(imageData, withName: "profile_image", fileName: "profile_image.jpg", mimeType: "image/jpeg")
                
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
                            print("updatecoverpic JSON: \(json)")
                            
                            let status = json["status"].stringValue.lowercased()
                            
                            if status == "success" {
                                
                                let image_url = json["data"]["image_url"].stringValue
                                
                                let url = URL.init(string: image_url)
                                
                                let block: SDWebImageCompletionBlock = {(image, error, cacheType, imageURL) -> Void in
                                    if let image = image {
                                        self.imageViewProfilePic.image = image.scaled(toWidth: self.imageViewProfilePic.frame.size.width * 2)
                                        self.imageViewEmpPic.image = image.scaled(toWidth: self.imageViewProfilePic.frame.size.width * 2)
                                    }
                                    AppDataSwift.dismissLoader(viewController: self)
                                    AppDataSwift.showAlert("Success!", andMsg: json["msg"].stringValue, andViewController: self)
                                }
                                
                                self.imageViewProfilePic.sd_setImage(with: url, completed: block)
                                
                                AppDataSwift.defaults.set(image_url, forKey: "profile_pic")
                                AppDataSwift.defaults.synchronize()
                                
                            } else {
                                
                                AppDataSwift.dismissLoader(viewController: self)
                                AppDataSwift.showAlert("Error!", andMsg: json["msg"].stringValue, andViewController: self)
                                
                            }
                            
                        case .failure(let error):
                            AppDataSwift.dismissLoader(viewController: self)
                            print("Server Error!: \(error.localizedDescription)")
                            AppDataSwift.showAlert("Error!", andMsg: "\(error.localizedDescription)", andViewController: self)
                        }
                        
                    }
                    
                case .failure(let encodingError):
                    AppDataSwift.dismissLoader(viewController: self)
                    AppDataSwift.showAlert("Error!", andMsg: encodingError.localizedDescription, andViewController: self)
                }
        })
    }

    

}
