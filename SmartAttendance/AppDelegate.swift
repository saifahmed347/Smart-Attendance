//
//  AppDelegate.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 07/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import ReachabilitySwift
import CoreLocation
import Alamofire
import SwiftyJSON
import Foundation
import UserNotifications
import Firebase



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let reachability = Reachability()
    let gcmMessageIDKey = "gcm.message_id" //AIzaSyAMMwPnTJdOk54OYGbF-qku9Oh0IYZUP-E
    
    public static let locationManager = CLLocationManager()
    
    public static var restrictRotation: Bool = true
    
    var app_user_default = AppDataSwift()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Check internet status
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification ,object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        //Location Manger
        AppDelegate.initializeLocationManager(withViewController: (self.window?.rootViewController)!)
        
        //Database
        Util.copyFile("\(AppData.getDatabaseName()!).sqlite")
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        
        if AppDataSwift.defaults.object(forKey: "FCMToken") == nil {
            let token = "c4EOH8j1e5s:APA91bG3BDhmSVMIxUlz0pRqraRwO9W2qJiaPnVrLY3iLZ3_IC5JXPougze-sFpYoMMg3ol70Ba04eDBLgjeo1KxWC4mTaa7vK-pJ5uA5yxt2scIQKu9arfyzrLMbVtLM7dwJV9WXY-v"
            AppDataSwift.defaults.set(token, forKey: "FCMToken")
            AppDataSwift.defaults.synchronize()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5 ) {
            AppDelegate.refreshFCMToken()
        }
        
        return true
        
    }
    
    
    @objc func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            AppDataSwift.isWifiConnected = true
            print("internet connected")
            self.syncToServer()
        } else {
            AppDataSwift.isWifiConnected = false
            print("internet not connected")
        }
    }
    
    public static func refreshFCMToken(){
        
        if let refreshedToken = InstanceID.instanceID().token() {
            
            print("InstanceID token: \(refreshedToken)")
            
            AppDataSwift.defaults.set(refreshedToken, forKey: "FCMToken")
            AppDataSwift.defaults.synchronize()
            
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        AppDelegate.initializeLocationManager(withViewController: (self.window?.rootViewController)!)
        
        if AppDataSwift.isWifiConnected {
            self.checkAppVersion()
        }
        
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if AppDelegate.restrictRotation {
            return UIInterfaceOrientationMask.portrait
        }
        else{
            return UIInterfaceOrientationMask.all
        }
    }
    
    // MARK: - Location Mangaer
    
    public static func initializeLocationManager(withViewController vc: UIViewController) {
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("location access denied")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self as! CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        } else {
            let alertController = UIAlertController (title: "Location Service Disabled!", message: "Location Service is not enabled. To enable it go to Settings > Privacy > Location Services than enable it.", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            vc.present(alertController, animated: true, completion: nil)

        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = Double((manager.location?.coordinate.latitude)!)
        let longitude = Double((manager.location?.coordinate.longitude)!)
        
        print("Appdelegte: latitude: \(latitude), longitude: \(longitude)")
        
        AppDataSwift.defaults.set(latitude, forKey: "latitude")
        AppDataSwift.defaults.set(longitude, forKey: "longitude")
        AppDataSwift.defaults.synchronize()
        
    }
    
    
    
    func syncToServer() {
        
        if AppDataSwift.defaults.bool(forKey: "isLogin") {
            
            let userId = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
            let dataArray = DBManager.getInstance().getAllAttendanceOfEmployee(withUserId: userId, andIsUploaded: "0")
            print("dataArray: \(dataArray!)")
            
            if (dataArray?.count)! > 0 {
                self.syncAttendance(withDataArray: dataArray!)
            }
            
            let imagesArray = DBManager.getInstance().getAllImages(withUserId: userId, andIsUploaded: "0")
            print("imagesArray: \(imagesArray!)")
            
            if (imagesArray?.count)! > 0 {
                
                self.syncImages(withUserId: userId, andImages: JSON(imagesArray!))
                
            }
            
        }
        
    }
    
    
    func syncAttendance(withDataArray dataArray: NSMutableArray) {
        
        let url = AppDataSwift.BASE_URL + "syncAttendance?user_id=" + "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        
        print("url: \(url)")
        
        var request = URLRequest(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = AppDataSwift.getHTTPHeader()
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: dataArray)
        
        Alamofire.request(request)
            .responseJSON { response in
                // do whatever you want here
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                    
                case .success(let responseObject):
                    
                    let json = JSON(responseObject)
                    print("json: \(json)")
                    
                    if json["status"].stringValue == "Success" {
                        DBManager.getInstance().updateAllRecodsIsUploadedColoum()
                    }
                    
                }
        }
    }
    
    
    func syncImages(withUserId userId: String, andImages imagesArray: JSON) {
        
        let url = AppDataSwift.BASE_URL + "syncImages"
        print("url: \(url)")
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                for i in 0 ..< imagesArray.count {
                    
                    let imageDataObj = imagesArray[i]
                    print("imageDataObj: \(imageDataObj)")
                    
                    let imageName = imageDataObj["image_name"].stringValue
                    print("imageName: \(imageName)")
                    
                    let image = AppDataSwift.getImageFromDocumentDirectory(withImageName: imageName)
                    print("image: \(image.size)")
                    
                    let imageData: Data = AppData.compressImage(AppData.resizeImageAccordingToWidth(with: image, scaledToWidth: 200.0))
                    
                    let imageKey = "attendance_images[\(i)]"
                    print("imageKey: \(imageKey)")
                    
                    multipartFormData.append(imageData, withName: imageKey, fileName: imageName, mimeType: "image/jpeg")
                }
                
                multipartFormData.append(userId.data(using: .utf8)!, withName: "user_id")
                
                print("multipartFormData: \(multipartFormData)")
                
        },
            to: url, headers: AppDataSwift.getHTTPHeader(),
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            print("syncImages JSON: \(json)")
                            
                            if json["status"].stringValue == "Success" {
                                
                                for i in 0 ..< imagesArray.count {
                                    
                                    let imageDataObj = imagesArray[i]
                                    print("imageDataObj: \(imageDataObj)")
                                    
                                    let imageName = imageDataObj["image_name"].stringValue
                                    print("imageName: \(imageName)")
                                    
                                    AppDataSwift.removeImageFromDocumentDirectory(withImageName: imageName)
                                    
                                    DBManager.getInstance().updateImagesUploadStatus(withUserId: userId, imageName: imageName, andIsUploaded: "1")
                                }
                                
                            }
                            
                        case .failure(let error):
                            print("syncImage error: \(error.localizedDescription)")
                        }
                    }
                case .failure(let encodingError):
                    print("sync images server error: \(encodingError.localizedDescription)")
                }
        })
    }
    
    func checkAppVersion() {
        
        var user_id = "0"
        
        if AppDataSwift.defaults.object(forKey: "user_id") != nil {
            user_id = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        }
        
        let url = AppDataSwift.BASE_URL + "checkAppVersion"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": user_id,
            "app_version": AppDataSwift.APP_VERSION
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("checkAppVersion JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    let force = json["force"].stringValue
                    
                    if force != "" {
                        
                        let dataObject = NSMutableDictionary.init()
                        dataObject.setValue(json["title"].stringValue, forKey: "title")
                        dataObject.setValue(json["msg"].stringValue, forKey: "msg")
                        dataObject.setValue(json["force"].stringValue, forKey: "force")
                        dataObject.setValue(json["app_version"].stringValue, forKey: "app_version")
                        
                        AppDataSwift.defaults.set(json["app_version"].stringValue, forKey: "app_version")
                        AppDataSwift.defaults.set(dataObject, forKey: "updateAppObject")
                        AppDataSwift.defaults.synchronize()
                        
                    }
                    
                    //Sync Attendance
                    /*
                    let attendance = json["attendance"].arrayValue
                    print("attendance.count: \(attendance)")
                    
                    if attendance.count > 0 {
                        for i in 0 ..< attendance.count {
                            let obj = attendance[i]
                            DBManager.getInstance().insertRecord(withUserId: obj["user_id"].string, andType: obj["type"].string, andLocation: obj["location"].string, andLocationCheckIn: obj["location_checkin"].string, andLocationOut: obj["location_checkout"].string, andDevice: obj["device"].string, andIMEI: obj["imei"].string, andDateOf: obj["dateof"].string, andTimeIn: obj["time_in"].string, andTimeOut: obj["time_out"].string, andTimeDifference: obj["time_diff"].string, andCreateTime: obj["created_time"].string, andUpdateTime: obj["updated_time"].string, andCheckInImage: obj["check_in_image"].string, andCheckOutImage: obj["check_out_image"].string, andIsUploaded: "1")
                        }
                    }
                     */
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    let message = json["msg"].stringValue
                    AppDataSwift.showAlert("Error!", andMsg: message, andViewController: (self.window?.rootViewController)!)
                }
                
            case .failure(let error):
                AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: (self.window?.rootViewController)!)
            }
            
        })
        
    }

    
    
    func readNotification(_ userInfo:[AnyHashable: Any]) {
        
        let json = JSON(userInfo)
        print("remoteMessage json: ", json)
        
        if json["gcm.notification.data"].exists() || json["notification"].exists() {
            
            //notification title
            
            var notificationTitle = ""
            
            if json["aps"]["alert"]["title"].exists() {
                
                notificationTitle = json["aps"]["alert"]["title"].stringValue
                
            }else if json["notification"]["title"].exists() {
                
                notificationTitle = json["notification"]["title"].stringValue
                
            }
            
            UserDefaults.standard.set(notificationTitle, forKey: "notificationTitle")
            UserDefaults.standard.synchronize()
            //end
            
            var mainDataString = json["gcm.notification.data"].stringValue
            
            if json["gcm.notification.data"].exists() {
                
                mainDataString = json["gcm.notification.data"].stringValue
                
            }else if json["notification"]["data"].exists() {
                
                mainDataString = json["notification"]["data"].stringValue
                
            }
            
            //Parse and save data
            let mainEncodedString : Data = mainDataString.data(using: .utf8)!
            
            let mainData = JSON.init(data: mainEncodedString)
            print("mainData: ", mainData)
            
            
            let data = mainData["data"]["data"]
            print("data: ", data)
            
            
            if let mySoundFile : String = json["sound"] as? String {
                playSound(fileName: mySoundFile)
            }
        }
        
    }
    
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        guard
            let aps = userInfo[AnyHashable("aps")] as? NSDictionary,
            let alert = aps["alert"] as? NSDictionary,
            let body = alert["body"] as? String,
            let title = alert["title"] as? String
            else{
                
                return
        }
        
        let date = Date()
        
        let timeStamp = AppData.getDateWithFormateString("dd MMM yyyy HH:mm a", andDateObject: date)
        
        
        var array = self.app_user_default.getPushNotification()
        
        array.insert(NotificationBean(idTimeStamp: timeStamp!, title: title, body: body, isRead: false), at: 0)
        
        self.app_user_default.savePushNotification(array)
        
        // Print full message.
        print(userInfo)
        
        self.readNotification(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([UNNotificationPresentationOptions.alert,
                           UNNotificationPresentationOptions.sound,
                           UNNotificationPresentationOptions.badge])
    }
    
    
    //This will run on user touch on backgroud notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        guard
            let aps = userInfo[AnyHashable("aps")] as? NSDictionary,
            let alert = aps["alert"] as? NSDictionary,
            let body = alert["body"] as? String,
            let title = alert["title"] as? String
            else{
                
                return
        }
        
        let date = Date()
        
        let timeStamp = AppData.getDateWithFormateString("dd MMM yyyy HH:mm a", andDateObject: date)
        
        
        var array = self.app_user_default.getPushNotification()
        
        array.insert(NotificationBean(idTimeStamp: timeStamp!, title: title, body: body, isRead: false), at: 0)
        
        self.app_user_default.savePushNotification(array)

        
        // Print full message.
        print(userInfo)
        
        self.readNotification(userInfo)
       
        
        
        
        completionHandler()
    }
    
    // Play the specified audio file with extension
    func playSound(fileName: String) {
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forAuxiliaryExecutable: fileName) {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
    
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("Received data message: \(remoteMessage.appData)")
        
        self.readNotification(remoteMessage.appData)
        
    }
    // [END ios_10_data_message]
}

/*
 
 {
 "status": "Success",
 "title": "You can't continue!",
 "msg": "You must update the app you are using old version which is deprecated",
 "force": 1,
 "app_version": "1.1",
 "attendace": [
 {
 "_id": "1178",
 "user_id": "15",
 "dateof": "2017-09-14",
 "time_in": "10:47:29",
 "time_out": "11:09:49",
 "time_diff": "00:22:20",
 "type": "checking",
 "location_checkin": "25.37565938100634,68.34933863329346",
 "location_checkout": null,
 "location": null,
 "user_ip": "192.168.4.34",
 "device": "iphone",
 "imei": "9E4EDA82-D93C-4CB7-A260-1",
 "created_time": "2017-09-14 10:47:29",
 "updated_time": "2017-09-14 11:09:49",
 "user_agent": "SmartAttendance/3.0 (com.gexton.SmartAttendance; build:4; iOS 10.2.0) Alamofire/4.4.0",
 "check_in_image": "2017/09/1505368049_employee_img.jpg",
 "check_out_image": "2017/09/1505369389_employee_img.jpg",
 "sync_data": "0",
 "checking_notify": "0"
 }
 ]
 }
 
 */


