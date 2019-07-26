//
//  AllLeavesViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 04/07/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class AllLeavesViewController: UIViewController {

    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!

    @IBOutlet weak var labelYear: UILabel!
    @IBOutlet weak var labelTotalLeaves: UILabel!
    @IBOutlet weak var labelAppliedLeaves: UILabel!
    @IBOutlet weak var labelApprovedLeaves: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    var leavesArray: JSON = JSON.null
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
    }
    
    @objc func refresh(sender:AnyObject) {
        
        if AppDataSwift.isWifiConnected {
            AppDataSwift.showLoader("", andViewController: self)
            self.allEmployeesLeaves()
        }else{
            AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
        }
        
        refreshControl?.endRefreshing()
    }

    
    override func viewWillAppear(_ animated: Bool) {

        if (AppDataSwift.defaults.object(forKey: "leavesArray") != nil) {
            
            let data = NSKeyedUnarchiver.unarchiveObject(with: AppDataSwift.defaults.object(forKey: "leavesArray") as! Data)
            self.leavesArray = JSON(data!)
            print("leavesArray: \(self.leavesArray)")
            
            self.tableView.reloadData()
            self.settingTotalValues()
            
        }else{
            
            if AppDataSwift.isWifiConnected {
                AppDataSwift.showLoader("", andViewController: self)
                self.allEmployeesLeaves()
            }else{
                AppDataSwift.noInternetConnectionFoundAlert(viewController: self)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
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
    
    
    @IBAction func btnApplyLeaveAction(_ sender: Any) {
        AppDataSwift.gotoApplyLeaveScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    
    
    //MARK: - HTTP Services
    
    func allEmployeesLeaves() {
        
        let company_id = "\(AppDataSwift.defaults.object(forKey: "company_id")!)"
        let user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        print("user_id: \(user_id)")
        
        
        let url = AppDataSwift.BASE_URL + "allEmployeesLeaves"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id,
            "company_id": company_id
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("allEmployeesLeaves JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    self.leavesArray = json["data"]
                    self.tableView.reloadData()
                    
                    //save data
                    
                    let currentYear = AppData.getDateWithFormateString("yyyy", andDateObject: Date())
                    
                    AppDataSwift.defaults.set(currentYear, forKey: "currentYear")
                    AppDataSwift.defaults.set(json["total_leaves"].stringValue, forKey: "total_leaves")
                    AppDataSwift.defaults.set(json["total_applied_leaves"].stringValue, forKey: "total_applied_leaves")
                    AppDataSwift.defaults.set(json["approved_leaves"].stringValue, forKey: "approved_leaves")
                    
                    AppDataSwift.defaults.set(NSKeyedArchiver.archivedData(withRootObject: json["data"].arrayObject!), forKey: "leavesArray")
                    AppDataSwift.defaults.synchronize()
                    
                    self.settingTotalValues()
                    
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
    
    
    func settingTotalValues(){
        
        self.labelYear.text = "\(AppDataSwift.defaults.object(forKey: "currentYear")!)"
        
        self.labelTotalLeaves.text = "\(AppDataSwift.defaults.object(forKey: "total_leaves")!)"
        
        self.labelAppliedLeaves.text = "\(AppDataSwift.defaults.object(forKey: "total_applied_leaves")!)"
        
        self.labelApprovedLeaves.text = "\(AppDataSwift.defaults.object(forKey: "approved_leaves")!)"
        
    }
    
    
    
}


extension AllLeavesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.leavesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 80.0
        } else {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        let labelFromToDate = cell.contentView.viewWithTag(1) as! UILabel
        let labelDays = cell.contentView.viewWithTag(2) as! UILabel
        let labelStatus = cell.contentView.viewWithTag(3) as! UILabel
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = .white
        }else{
            cell.contentView.backgroundColor = AppData.color(fromHexString: "#E5E5E5", andAlpha: 1.0)
        }
        
        let obj = self.leavesArray[indexPath.row]
        
        //Date
        let date_from = obj["date_from"].stringValue
        let date_from_obj = AppData.getDateObjectFromString(withTime: date_from, andDateFormat: "yyyy-MM-dd")
        if let required_date_from_str = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: date_from_obj) {
            labelFromToDate.text = required_date_from_str
        }
        
        let date_to = obj["date_to"].stringValue
        let date_to_obj = AppData.getDateObjectFromString(withTime: date_to, andDateFormat: "yyyy-MM-dd")
        if let required_date_to_str = AppData.getDateWithFormateString("dd/MM/yyyy", andDateObject: date_to_obj) {
            labelFromToDate.text = labelFromToDate.text! + " - " + required_date_to_str
        }
        
        labelDays.text = obj["total_days"].stringValue
        
        let status = obj["status"].stringValue

        if status == "approved" {
            
            labelStatus.text = "Approved"
            labelStatus.textColor = AppData.color(fromHexString: "#43A047", andAlpha: 1.0)
            
        } else if status == "rejected" {
        
            labelStatus.text = "Rejected"
            labelStatus.textColor = AppData.color(fromHexString: "#FF4445", andAlpha: 1.0)
            
        } else {
        
            labelStatus.text = "Pending"
            labelStatus.textColor = AppData.color(fromHexString: "#FB6816", andAlpha: 1.0)
            
        }
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LeaveDetailPopUpViewController") as! LeaveDetailPopUpViewController
        vc.dataObject = self.leavesArray[indexPath.row]
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
}



/*
 
 {
 "status": "Success",
 "code": 200,
 "total_applied_leaves": 2,
 "approved_leaves": 0,
 "leaves_left": 24,
 "data": [
 {
 "_id": "2",
 "employee_id": "10",
 "leave_reason": "Esi he dil kr rha hai",
 "date_from": "2017-06-23",
 "date_to": "2017-06-23",
 "total_days": "1",
 "reason_id": "2",
 "created_on": "2017-06-23 15:45:45",
 "is_seen": "0",
 "reason": "Emergency"
 },
 {
 "_id": "1",
 "employee_id": "10",
 "leave_reason": "Esi he dil kr rha hai",
 "date_from": "2017-06-23",
 "date_to": "2017-06-23",
 "total_days": "1",
 "reason_id": "2",
 "created_on": "2017-06-23 14:06:15",
 "is_seen": "0",
 "reason": "Emergency"
 }
 ]
 }
 
 */
