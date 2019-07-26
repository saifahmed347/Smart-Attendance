//
//  LateCheckOutPopUpViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/22/18.
//  Copyright © 2018 Gexton. All rights reserved.
//

import UIKit

protocol LateCheckOutPopUpViewControllerDelegate {
    func dismissLateCheckOutPopUpViewController()
}

class LateCheckOutPopUpViewController: UIViewController {
    
        var delegate: LateCheckOutPopUpViewControllerDelegate? = nil
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTakeCare: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelAM: UILabel!
    
    var empImage: UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.settingValues()
    }
    
    func settingValues() {
        self.imageView.image = self.empImage
        self.labelTakeCare.text = "Take Care \(AppDataSwift.defaults.object(forKey: "name")!)"
        self.labelTime.text = AppData.getDateWithFormateString("hh:mm", andDateObject: Date())
        self.labelAM.text = AppData.getDateWithFormateString("a", andDateObject: Date())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ){
            AppData.setBorderWith(self.imageView, andBorderWidth: 1.0, andBorderColor: .clear, andBorderRadius: self.imageView.frame.size.height / 2 )
        }
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        
        if self.delegate != nil {
            self.delegate?.dismissLateCheckOutPopUpViewController()
        }
        
        self.dismiss(animated: true, completion: nil)
    }


}
