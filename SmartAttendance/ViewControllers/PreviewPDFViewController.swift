//
//  PreviewPDFViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 9/11/17.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit

class PreviewPDFViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    let path = "\(NSTemporaryDirectory())history_file.pdf"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        AppDelegate.restrictRotation = false
        
        if let url = URL(string: path) {
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        AppDelegate.restrictRotation = true
        self.dismiss(animated: true, completion: nil)
    }
}
