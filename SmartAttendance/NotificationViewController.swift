//
//  NotificationViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/24/18.
//  Copyright © 2018 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    var arrayNotifications = [NotificationBean]()
    var app_user_default = AppDataSwift()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notFoundLbl: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.arrayNotifications = self.app_user_default.getPushNotification()

        if (self.arrayNotifications.count > 0){
            
            self.notFoundLbl.isHidden = true
            self.tableView.isHidden = false
        }
        else{
            
            self.notFoundLbl.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
        self.updateAllNotificationsList(self.arrayNotifications)
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
    
    @IBAction func btnRemoveAllNotificatioAction(_ sender: Any) {
        
        let alertController = UIAlertController.init(title: "Delete All Notifications!", message: "Are you sure you want to delete all notifications?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction.init(title: "Yes", style: .default, handler: { action in
            
            self.arrayNotifications.removeAll()
            self.deleteAllNotificationFromUserDefault()
            self.tableView.reloadData()
        })
        
        let noAction = UIAlertAction.init(title: "No", style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true, completion: nil)

        
        
    }
    
    func deleteNotificationFromUserDefault(_ date : String){
        
        var array = self.app_user_default.getPushNotification()
        for(index, obj) in array.enumerated(){
            
            if(obj.idTimeStamp == date){
                
                array.remove(at: index)
                self.app_user_default.savePushNotification(array)
                break
            }
            
        }
        
    }
    
    func deleteAllNotificationFromUserDefault(){
        
        var array = self.app_user_default.getPushNotification()
        for(index, obj) in array.enumerated(){
            
                array.remove(at: index)
                self.app_user_default.savePushNotification(array)
                break
        }
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
    
    // -MARK tableView delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        
        cell.titleLbl.text = "\(self.arrayNotifications[indexPath.row].title)"
        cell.bodyLbl.text = "\(self.arrayNotifications[indexPath.row].body)"
        cell.dateLbl.text = "\(self.arrayNotifications[indexPath.row].idTimeStamp)"
        
        if (!(self.arrayNotifications[indexPath.row].isRead)) {
            
            cell.backgroundColor = UIColor(red: 251/255, green: 120/225, blue: 57/255, alpha: 1)
            cell.bgView.backgroundColor =  UIColor(red: 251/255, green: 120/225, blue: 57/255, alpha: 1)
        }
        else{
            
            cell.backgroundColor = UIColor(red: 255/255, green: 255/225, blue: 255/255, alpha: 1)
            cell.bgView.backgroundColor =  UIColor(red: 255/255, green: 255/225, blue: 255/255, alpha: 1)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, index) in

            self.arrayNotifications.remove(at: indexPath.row)
//        self.deleteNotificationFromUserDefault(self.arrayNotifications[indexPath.row].idTimeStamp)
            
            self.app_user_default.savePushNotification(self.arrayNotifications)
            self.tableView.reloadData()
        }
        return [delete]
    }
    
    func updateAllNotificationsList(_ list: [NotificationBean]){
        var tempList = [NotificationBean]()
        
        for(index, var obj) in list.enumerated(){
            
            obj.isRead = true
            tempList.append(obj)
        }
        
        self.app_user_default.savePushNotification(tempList)
    }
    
 

}
