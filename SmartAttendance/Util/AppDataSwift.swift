//
//  AppDataSwift.swift
//  GCMS
//
//  Created by Samir on 2016-11-29.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit
import QuartzCore
import MRProgress
import CoreLocation
import Alamofire
import SwiftyJSON

class AppDataSwift: NSObject {
    
    public static var defaults = UserDefaults.standard
    public static var isWifiConnected = false
    
    public static let APP_VERSION = "1.1"
    
    var userdefault : UserDefaults?
    
    override init() {
        
        self.userdefault = UserDefaults.standard
    }
    
    //    public static let BASE_URL = "http://server.gexton.com/smart_attendance/index.php/api/v1/emplyoees/"
    //    public static let BASE_URL = "http://192.168.4.15/smart_attendance/index.php/api/v2/emplyoees/"
    public static let BASE_URL = "http://smartattendanceapp.com/system/api/v2/emplyoees/"
    
    public static let USER_ID = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
    public static let DATE = "2017-06-04"
    
    public static func animateTable(_ tableView: UITableView) {
        
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
            
        }
    }
    
    public func savePushNotification(_ obj : [NotificationBean]){
        
        if let encoded = try? JSONEncoder().encode(obj){
            
            self.userdefault?.set(encoded, forKey: "push-notification")
            self.userdefault?.synchronize()
        }
    }
    
    public func getPushNotification()->[NotificationBean]{
        
        var obj = [NotificationBean]()
        
        if let userData = self.userdefault?.data(forKey: "push-notification"){
            
            obj = try! JSONDecoder().decode([NotificationBean].self, from: userData)
        }
        
        return obj
    }
    
    public static func showOrHideView(_ view: UIView, andIsHidden isHidden: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0.4, options: .transitionCrossDissolve, animations: {
            view.isHidden = isHidden
        }, completion: nil)
    }
    
    public static func changeLabelTextColor(_ lbl: UILabel, andColor color: UIColor) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .transitionCrossDissolve, animations: {
            lbl.textColor = color
        }, completion: nil)
    }
    
    public static func changeViewBackgroundColor(_ view: UIView, andColor color: UIColor) {
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .transitionFlipFromRight, animations: {
            view.backgroundColor = color
        }, completion: nil)
    }
    
    
    public static func showAlert(_ title: String, andMsg msg: String, andViewController vc: UIViewController) {
        let alertController = UIAlertController.init(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        let alertActionOK = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(alertActionOK)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    public static func noInternetConnectionFoundAlert(viewController vc: UIViewController) {
        AppDataSwift.showAlert("Error!", andMsg: "No internet connection found", andViewController: vc)
    }
    
    
    public static func showLoader(_ title: String, andViewController vc: UIViewController){
        let progressView = MRProgressOverlayView()
        progressView.titleLabelText = "Please wait..."
        progressView.tintColor = UIColor.orange
        progressView.mode = MRProgressOverlayViewMode.indeterminateSmall
        vc.view.addSubview(progressView)
        progressView.show(true)
    }
    
    public static func dismissLoader(viewController vc: UIViewController){
        MRProgressOverlayView.dismissOverlay(for: vc.view, animated: true)
    }
    
    public static func shakeTextField(_ txtField: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue.init(cgPoint: CGPoint.init(x: txtField.center.x - 10, y: txtField.center.y))
        animation.toValue = NSValue.init(cgPoint: CGPoint.init(x: txtField.center.x + 10, y: txtField.center.y))
        txtField.layer.add(animation, forKey: "position")
    }
    
    
    public static func changeTextFieldPlaceHolderColor(_ txtField: UITextField, text txt: String,andColor color: UIColor) {
        txtField.attributedPlaceholder = NSAttributedString(string: txt, attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    
    
    public static func getCLLocationCoordinate2DObj(_ lat: String, _ lng: String) -> CLLocationCoordinate2D {
        if let latStr = NumberFormatter().number(from: lat), let lngStr = NumberFormatter().number(from: lng) {
            let lat = CGFloat(latStr)
            let lng = CGFloat(lngStr)
            print("lat: \(lat), lng: \(lng)")
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        } else {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(0.0), longitude: CLLocationDegrees(0.0))
        }
    }
    
    
    public static func convertJSONToString(_ json: JSON) -> String {
        
        print("json: \(json)")
        
        do {
            
            let data = try json.rawData()
            
            let convertedString = String(data: data, encoding: String.Encoding.utf8)! // the data will be converted to the string
            print("convertedString: \(convertedString)")
            
            return convertedString
            
        } catch let myJSONError {
            print(myJSONError)
        }
        
        return ""
        
    }
    
    
    
    public static func getHTTPHeader() -> HTTPHeaders {
        
        AppDelegate.refreshFCMToken()
        
        var device_token = ""
        
        if AppDataSwift.defaults.object(forKey: "FCMToken") != nil {
            device_token = "\(AppDataSwift.defaults.object(forKey: "FCMToken")!)"
        }else{
            AppDelegate.refreshFCMToken()
        }
        
        print("device_token: \(device_token)")
        
        let headers: HTTPHeaders = [
            "devicetoken": device_token,
            "platform": "ios",
            "Authorization": "Basic c21hcnRfYXR0ZW5kYW5jZV92MjokJTdXVilWRVVkREJAOTRAVG5KSzIqMjR5VQ=="
        ]
        
        return headers
    }
    
    
    //MARK: Navigations
    
    public static func gotoLoginScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoHomeScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoManualAttendanceScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManualAttendanceViewController") as! ManualAttendanceViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoManualAttendancePopUp(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManualAttendancePopUpViewController") as! ManualAttendancePopUpViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    
    public static func gotoProfileScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoHistoryScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    
    public static func gotoAboutUsScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoNotificationScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoLeaveScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllLeavesViewController") as! AllLeavesViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoApplyLeaveScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeaveViewController") as! LeaveViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoScannerScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoFaceDetectionScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FaceDetectionViewController") as! FaceDetectionViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    public static func gotoBreakScreen(withNavigationController navigationController: UINavigationController, andIsAnimated animated: Bool){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BreakViewController") as! BreakViewController
        navigationController.pushViewController(vc, animated: animated)
    }
    
    
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    public static func getImageName(withUserId userId: String, andDate date: Date) -> String {
        //2017_06_03_T_18_50_ID_10
        let imgName = String(format: "%@_ID_%@.jpg", AppData.getDateWithFormateString("yyyy'_'MM'_'dd'_T_'HH'_'mm", andDateObject: date), "\(AppDataSwift.defaults.object(forKey: "user_id")!)")
        print("imgName: ", imgName)
        return imgName
    }
    
    public static func saveImageInDocumentDirectory(withImage image: UIImage, andImageName imgName: String) {
        if let data = image.jpegData(compressionQuality: 0.8){ //UIImageJPEGRepresentation(image, 0.8) {
            let filePath = AppDataSwift.getDocumentsDirectory().appendingPathComponent(imgName)
            print("filePath: \(filePath)")
            try? data.write(to: filePath)
            print("image saved. file exist: \(FileManager.default.fileExists(atPath: filePath.path))")
            
        }else{
            print("error in converting image")
            
        }
    }
    
    public static func getImageFromDocumentDirectory(withImageName imgName: String) -> UIImage {
        
        let filePath = AppDataSwift.getDocumentsDirectory().appendingPathComponent(imgName)
        print("filePath: \(filePath)")
        print("getting image file exist: \(FileManager.default.fileExists(atPath: filePath.path))")
        
        if let image = UIImage(contentsOfFile: filePath.path) {
            return image
        }else{
            return UIImage()
        }
        
    }
    
    public static func removeImageFromDocumentDirectory(withImageName imgName: String) {
        
        do {
            let filePath = AppDataSwift.getDocumentsDirectory().appendingPathComponent(imgName)
            print("filePath: \(filePath)")
            print("before removing file exist: \(FileManager.default.fileExists(atPath: filePath.path))")
            try FileManager.default.removeItem(at: filePath)
            print("after removing file exist: \(FileManager.default.fileExists(atPath: filePath.path))")
        } catch {
            print("Could not delete clear \(imgName): \(error)")
        }
        
        
    }
    
    
    public static func generatePDF(username: String, total_duration: String, dataArray: JSON, attendanceFor: String) {
        
        let pathToHistoryDetailTemplate = Bundle.main.path(forResource: "HistoryDetailTemplate", ofType: "html")
        let pathToItem = Bundle.main.path(forResource: "Item", ofType: "html")
        let logoImageURL = "http://smartattendanceapp.com/system/assets/imgs/sas_white.png"
        
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToHistoryDetailTemplate!)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO#", with: logoImageURL)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#USERNAME#", with: username)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ATTENDANCE_FOR#", with: attendanceFor)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTAL_DURATION#", with: total_duration)
            
            // The invoice items will be added by using a loop.
            var allItems = ""
            
            for i in 0 ..< dataArray.count {
                
                let obj = dataArray[i]
                print("obj for item: \(obj)")
                
                //Date
                let date = obj["dateof"].stringValue
                let dateObj = AppData.getDateObjectFromString(withTime: date, andDateFormat: "yyyy-MM-dd")
                let requiredDateString = AppData.getDateWithFormateString("EEE, d MMM yyyy", andDateObject: dateObj)
                
                let timeZone = NSTimeZone.local
                
                let timeIn = obj["time_in"].stringValue
                let timeInObj = AppData.getDateObjectFromString(withTime: timeIn, andDateFormat: "HH:mm:ss", andTimeZone: timeZone)
                let requiredTimeInString = AppData.getDateWithFormateString("hh:mm a", andDateObject: timeInObj)
                
                let timeOut = obj["time_out"].stringValue
                var requiredTimeOutString = "-"
                if timeOut != "" {
                    let timeOutObj = AppData.getDateObjectFromString(withTime: timeOut, andDateFormat: "HH:mm:ss", andTimeZone: timeZone)
                    requiredTimeOutString = AppData.getDateWithFormateString("hh:mm a", andDateObject: timeOutObj)
                }
                
                //break
                let break_total_time_in_seconds = obj["breaks"]["total_time"].intValue
                
                let hours = break_total_time_in_seconds / 3600
                let minutes = (break_total_time_in_seconds - (hours * 3600)) / 60
                let seconds = break_total_time_in_seconds % 60
                
                print("total time: \(break_total_time_in_seconds), hours: \(hours), minutes: \(minutes), seconds: \(seconds)")
                
                let break_duration = String(format: "%zdhrs, %zdmins, %zdsec", hours, minutes, seconds)
                
                
                //total time duration
                let total_time_duration = obj["total_time_duration"].stringValue
                print("total_time_duration: \(total_time_duration)")
                
                let timeInHrs = Int(total_time_duration.substring(with: 0 ..< 2))
                let timeInMin = Int(total_time_duration.substring(with: 3 ..< 5))
                let timeInSec = Int(total_time_duration.substring(with: 6 ..< 8))
                print("timeInSec: \(timeInSec!), timeInMin: \(timeInMin!), timeInHrs: \(timeInHrs!), ")
                
                var duration = String(format: "%zdhrs, %zdmins, %zdsec", timeInHrs!, timeInMin!, timeInSec!)
                
                if requiredTimeOutString == "-" {
                    duration = "-"
                }
                
                var itemHTMLContent: String!
                
                itemHTMLContent = try String(contentsOfFile: pathToItem!)
                
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#S_NO#", with: "\(i+1)")
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DATE#", with: requiredDateString!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#CHECK_IN#", with: requiredTimeInString!)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#CHECK_OUT#", with: requiredTimeOutString)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#BREAK#", with: break_duration)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DURATION#", with: duration)
                
                
                // Add the item's HTML code to the general items string.
                allItems += itemHTMLContent
            }
            
            // Set the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            
            AppDataSwift.createAndStorePDF(html: HTMLContent)
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
    }
    
    
    public static func createAndStorePDF(html: String) {
        
        // 1. Create a print formatter
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 80) //bottom margin for multi pages
        
        render.setValue(page, forKey: "paperRect")
        render.setValue(printable, forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        for i in 0...render.numberOfPages - 1 {
            
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i , in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        let path = "\(NSTemporaryDirectory())history_file.pdf"
        pdfData.write(toFile: path, atomically: true)
        print("open \(path)") // command to open the generated file
        
    }
    
    
}



/*
 
 {
 "_id": "3",
 "user_id": "2",
 "dateof": "2017-06-12",
 "time_in": "10:15:11",
 "time_out": null,
 "location": "25.37548479985817,68.34915026604774",
 "type": "checking",
 "total_time": null,
 "break_time_in": "10:15:11",
 "break_time_out": null,
 "total_time_duration": "23:58:42",
 "breaks": {
 "total_time": "12",
 "break_time_in": [
 "10:16:18",
 "10:22:43",
 "10:39:32",
 "10:42:36"
 ],
 "break_time_out": [
 "10:16:30",
 "10:23:14",
 "10:39:48",
 "10:42:55"
 ]
 }
 }
 
 <tr>
 <td class='padding: 5px; border: 1px solid #eee; font-size: 13px; color:#666;' >#S_NO#</td>
 <td class='padding: 5px; border: 1px solid #eee; font-size: 13px; color:#666;' >#DATE#</td>
 <td class='padding: 5px; border: 1px solid #eee; font-size: 13px; color:#666;' >#CHECK_IN#</td>
 <td class='padding: 5px; border: 1px solid #eee; font-size: 13px; color:#666;' >#CHECK_OUT#</td>
 <td class='padding: 5px; border: 1px solid #eee; font-size: 13px; color:#666;' >#DURATION#</td>
 </tr>
 */











