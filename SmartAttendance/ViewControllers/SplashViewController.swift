//
//  SplashViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 07/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import SwiftyJSON

class SplashViewController: UIViewController {

    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
 
        
        if AppDataSwift.defaults.object(forKey: "QRCodeValue") == nil {
            AppDataSwift.defaults.set("Vm0weE1GbFhTWGxTYmtwUVZtMVNVMWxyVm5kVmJGcHlWV3RLVUZWVU1Eaz0=", forKey: "QRCodeValue")
            AppDataSwift.defaults.synchronize()
        }
        
        // Do any additional setup after loading the view.
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.navigate), userInfo: nil, repeats: true)
        
    }


    func substring(with r: Range<Int>) -> String {
        let startIndex = index(ofAccessibilityElement: r.lowerBound)
        let endIndex = index(ofAccessibilityElement: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    @objc func navigate() {
        
        self.timer?.invalidate()
        
        if AppDataSwift.defaults.bool(forKey: "isLogin") {
        
            if AppDataSwift.defaults.bool(forKey: "isLoginWithFigerPrint") {
                AppDataSwift.gotoLoginScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
            }else{
                if AppDataSwift.defaults.bool(forKey: "isBreakStarted") {
                    AppDataSwift.gotoBreakScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
                }else{
                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
                }
            }
            
        }else{
            
            AppDataSwift.gotoLoginScreen(withNavigationController: self.navigationController!, andIsAnimated: true)
            
        }
        
    }

    
}

