//
//  UpdateAppViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 9/14/17.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdateAppViewController: UIViewController {

    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    
    @IBOutlet weak var btnNotNow: UIButton!
    @IBOutlet weak var btnUpdateNow: UIButton!
    @IBOutlet weak var viewSeparater: UIView!
    
    var dataObject = JSON.null
    
    @IBOutlet weak var btnMustUpdateNow: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.settingValues()
    }

    func settingValues(){
        
        self.labelTitle.text = self.dataObject["title"].stringValue
        self.labelVersion.text = "v" + self.dataObject["app_version"].stringValue
        self.labelMessage.text = self.dataObject["msg"].stringValue
        
        let force = self.dataObject["force"].stringValue
        
        if force == "1" {
            self.btnMustUpdateNow.isHidden = false
            self.btnNotNow.isHidden = true
            self.btnUpdateNow.isHidden = true
            self.viewSeparater.isHidden = true
        }
        
    }
    
    
    @IBAction func btnNotNowAction(_ sender: Any) {
        
        let notShowVersion = self.dataObject["app_version"].stringValue
        AppDataSwift.defaults.set(notShowVersion, forKey: "notShowVersion")
        AppDataSwift.defaults.synchronize()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnUpdateNowAction(_ sender: Any) {
        self.openAppLink()
    }
    
    @IBAction func btnMustUpdateNowAction(_ sender: Any) {
        self.openAppLink()
    }
    
    func openAppLink(){
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1247431899?ls=1&mt=8")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
}


/*
 
 "status": "Success",
 "title": "You can't continue!",
 "msg": "You must update the app you are using old version which is deprecated",
 "force": 1,
 "app_version": "1.1",
 
 */
