//
//  FaceDetectionViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 08/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class FaceDetectionViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, CheckInPopUpViewControllerDelegate, CheckOutPopUpViewControllerDelegate, ManualAttendancePopUpViewControllerDelegate{
    
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    @IBOutlet weak var labelHi: UILabel!
    
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var viewTabBar: UIView!
    
    
    @IBOutlet weak var camerBTN: UIButton!
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image:UIImage?

    
    //Scanner
//    var captureDevice : AVCaptureDevice?
//
//    var captureSession: AVCaptureSession?
//    var previewLayer: AVCaptureVideoPreviewLayer?
//    var qrCodeFrameView: UIView?
//
//    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
//                              AVMetadataObject.ObjectType.code39,
//                              AVMetadataObject.ObjectType.code39Mod43,
//                              AVMetadataObject.ObjectType.code93,
//                              AVMetadataObject.ObjectType.code128,
//                              AVMetadataObject.ObjectType.ean8,
//                              AVMetadataObject.ObjectType.ean13,
//                              AVMetadataObject.ObjectType.aztec,
//                              AVMetadataObject.ObjectType.pdf417,
//                              AVMetadataObject.ObjectType.qr]
//
    var imagePicker = UIImagePickerController()
    var chosenImage = UIImage()
    
//    private func setupPreviewLayer(session: AVCaptureSession) {
//                previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer?.frame = cameraView.layer.bounds
//        previewLayer?.videoGravity = .resizeAspectFill
//
//        cameraView.layer.addSublayer(previewLayer!)
//
////        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
////        videoPreviewLayer?.frame = cameraView.layer.bounds
////        videoPreviewLayer?.videoGravity = .resizeAspectFill
////
////        cameraView.layer.addSublayer(videoPreviewLayer!)
//    }
//
//    // MARK - Bounding Box
//    private var boundingBox = CAShapeLayer()
//    private func setupBoundingBox() {
//        boundingBox.frame = cameraView.layer.bounds
//        boundingBox.strokeColor = UIColor.green.cgColor
//        boundingBox.lineWidth = 2.0
//        boundingBox.fillColor = UIColor.clear.cgColor
//
//        cameraView.layer.addSublayer(boundingBox)
//    }
//
//    fileprivate func updateBoundingBox(_ points: [CGPoint]) {
//        guard let firstPoint = points.first else {
//            return
//        }
//
//        let path = UIBezierPath()
//        path.move(to: firstPoint)
//
//        var newPoints = points
//        newPoints.removeFirst()
//        newPoints.append(firstPoint)
//
//        newPoints.forEach { path.addLine(to: $0) }
//
//        boundingBox.path = path.cgPath
//        boundingBox.isHidden = false
//    }
//
//    private var resetTimer: Timer?
//    fileprivate func hideBoundingBox(after: Double) {
//        resetTimer?.invalidate()
//        resetTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval() + after,
//                                          repeats: false) {
//                                            [weak self] (timer) in
//                                            self?.resetViews() }
//    }
//
//    private func resetViews() {
//        boundingBox.isHidden = true
//    }
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        self.setScanner()
        self.setImagePickerView()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        self.cameraView.addSubview(self.camerBTN)
        self.view.addSubview(self.camerBTN)
        
        
        
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        
        currentCamera = frontCamera
    }
    
    
    
    
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.cameraView.frame
//        self.cameraView.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        self.view.layer.addSublayer(cameraPreviewLayer!)
//        self.view.addSubview(self.camerBTN)
        
    }
    
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    @IBAction func camerBtnAction(_ sender: Any) {
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTopBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
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
    
    
    //MARK: - Scanner
    
//    func setScanner() {
//
//        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
//
//        self.captureSession?.beginConfiguration()
//
//        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
//        //AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
//        //AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
//
//        do {
//            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
//            let input = try AVCaptureDeviceInput(device: captureDevice)
//
//            // Initialize the captureSession object.
//            captureSession = AVCaptureSession()
//
//            // Set the input device on the capture session.
//            captureSession?.addInput(input)
//
//            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
//            let captureMetadataOutput = AVCaptureMetadataOutput()
//            captureSession?.addOutput(captureMetadataOutput)
//
//
//            // Set delegate and use the default dispatch queue to execute the call back
//            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face] //supportedCodeTypes
//
//            self.captureSession?.commitConfiguration()
//
//
//            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
////            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
////            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
////            previewLayer?.frame = self.cameraView.layer.bounds
////            self.cameraView.layer.addSublayer(previewLayer!)
////
////            // Start video capture.
////            captureSession?.startRunning()
////
////            // Move the message label and top bar to the front
//////            view.bringSubviewToFront(self.viewTopBar)
//////            view.bringSubviewToFront(self.viewTabBar)
////
////            // Initialize QR Code Frame to highlight the QR code
////            qrCodeFrameView = UIView()
////
////            if let qrCodeFrameView = qrCodeFrameView {
////                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
////                qrCodeFrameView.layer.borderWidth = 2
////                view.addSubview(qrCodeFrameView)
////                view.bringSubviewToFront(qrCodeFrameView)
////            }
//
//            DispatchQueue.main.async {
//                self.setupPreviewLayer(session: self.captureSession!)
//                self.setupBoundingBox()
//            }
//
//
//            captureSession?.startRunning()
//
//        } catch {
//            // If any error occurs, simply print it out and don't continue any more.
//            print(error)
//            return
//        }
//
//    }
    
//    func startScanner() {
//
//        if self.captureSession != nil {
//            if !(self.captureSession?.isRunning)! {
//                self.captureSession?.startRunning()
//            }
//        }
//
//    }
//
//    func stopScanner() {
//        if self.captureSession != nil {
//            if ((self.captureSession?.isRunning)!) {
//                self.captureSession?.stopRunning()
//            }
//        }
//    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
//
//
//        // Check if the metadataObjects array is not nil and it contains at least one object.
//        if metadataObjects == nil || metadataObjects.count == 0 {
//            qrCodeFrameView?.frame = CGRect.zero
//            print("No QR/barcode is detected")
//            return
//        }
//
//
//        for metadataObject in metadataObjects as! [AVMetadataObject] {
//
//            self.stopScanner()
//
//            if metadataObject.type == AVMetadataObject.ObjectType.face {
//                let transformedMetadataObject = previewLayer?.transformedMetadataObject(for: metadataObject)
//                qrCodeFrameView?.frame = transformedMetadataObject!.bounds
//
//                self.stopScanner()
//
//                self.present(self.imagePicker, animated: false, completion: nil)
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//                    self.imagePicker.takePicture()
//                }
//
//            }
//        }
//
//    }
    
    
    func setImagePickerView() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            self.imagePicker.showsCameraControls = false
            self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            
        } else {
            AppDataSwift.showAlert("No Camera!", andMsg: "Your device doesn't have camera", andViewController: self)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        
        chosenImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        self.imagePicker.dismiss(animated: false, completion: nil)
        
        let userId = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
        let imei = "\(UIDevice.current.identifierForVendor?.uuidString ?? "imei")"
        let location = "\(AppDataSwift.defaults.object(forKey: "latitude")!),\(AppDataSwift.defaults.object(forKey: "longitude")!)"
        let dateObj = Date()
        let date = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: dateObj)
        let time = AppData.getDateWithFormateString("HH:mm:ss", andDateObject: dateObj)
        var attendanceFor = "time_in"
        
        if AppDataSwift.defaults.bool(forKey: "isOpenScannerForCheckIn") {
            attendanceFor = "time_in"
        }else{
            attendanceFor = "time_out"
        }
        
        if AppDataSwift.isWifiConnected{
            
            AppDataSwift.showLoader("", andViewController: self)
            self.markAttendance(withUserId: userId, withType: "checking", andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andAttendanceFor: attendanceFor, andEmployeeImage: chosenImage, andDateObj: dateObj)
            
        }
        else
        {
            
            self.markAttendanceOffline(withUserId: userId, withType: "checking", andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andEmployeeImage: chosenImage, andDateObj: dateObj, andIsUploaded: "0")
            
        }
        
        
    }
    
    
    //MARK: - HTTP Service
    
    func markAttendance(withUserId userId: String, withType type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andAttendanceFor attendanceFor: String, andEmployeeImage empImage: UIImage, andDateObj dateObj: Date) {
        
        print("type: \(type), location: \(location), date: \(date), attendanceFor: \(attendanceFor)")
        
        let url = AppDataSwift.BASE_URL + "markAttendance"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": userId,
            "type": type,
            "location": location,
            "device": "iphone",
            "imei": imei,
            "dateof": date,
            "timeof": time,
            "attendance_for": attendanceFor,
        ]
        
        
        Alamofire.upload(
            
            multipartFormData: { multipartFormData in
                
                let imageData: Data = AppData.compressImage(AppData.resizeImageAccordingToWidth(with: empImage, scaledToWidth: 200.0))
                
                multipartFormData.append(imageData, withName: "employee_img", fileName: "employee_img.jpg", mimeType: "image/jpeg")
                
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
                            print("saveProfile JSON: \(json)")
                            
                            if json["status"].stringValue == "Success" {
                                
                                //Save in database
                                self.markAttendanceOffline(withUserId: userId, withType: "checking", andLocation: location, andIMEI: imei, andDate: date, andTime: time,andEmployeeImage: empImage, andDateObj: dateObj, andIsUploaded: "1")
                                
                                
                            } else if json["status"].stringValue.localizedLowercase == "error" {
                                
                                //                                AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                                let message = json["msg"].stringValue
                                
                                print("--- this is info message : \(message)")
                                
                                
                                if message == "Day time has been ended!"{
                                    
                                    //                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ManualAttendancePopUpViewController") as! ManualAttendancePopUpViewController
                                    
                                    
                                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManualAttendancePopUpViewController") as! ManualAttendancePopUpViewController
                                    
                                    
                                    vc.userID = userId
                                    vc.type = type
                                    vc.location = location
                                    vc.device = "iphone"
                                    vc.imei = imei
                                    vc.attendanceFor = attendanceFor
                                    vc.employeeIMG = empImage
                                    vc.delegate = self
                                    
                                    
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                    //                                self.present(vc, animated: true, completion: nil)
                                }
                                else{
                                    
                                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                                    
                                    AppDataSwift.showAlert("Info!", andMsg: message, andViewController: self)
                                }
                                
                                
                                
                            }
                            
                        case .failure(let error):
                            
                            AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                            AppDataSwift.showAlert("Server Error!", andMsg: error.localizedDescription, andViewController: self)
                            
                        }
                        
                        AppDataSwift.dismissLoader(viewController: self)
                        
                    }
                    
                case .failure(let encodingError):
                    
                    AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    AppDataSwift.showAlert("Error!", andMsg: encodingError.localizedDescription, andViewController: self)
                    
                }
                
        })
        
    }
    
    
    func markAttendanceOffline(withUserId userId: String, withType type: String, andLocation location: String, andIMEI imei: String, andDate date: String, andTime time: String, andEmployeeImage empImage: UIImage, andDateObj dateObj: Date, andIsUploaded isUploaded: String) {
        
        //Offline
        let imageName = AppDataSwift.getImageName(withUserId: userId, andDate: dateObj)
        
        if AppDataSwift.defaults.bool(forKey: "isOpenScannerForCheckIn") {
            
            if !DBManager.getInstance().isAlreadyCheckin(withUserId: userId, andDateOf: date, andType: "checking") {
                
                DBManager.getInstance().markAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_in", andImageName: imageName, andIsUploaded: isUploaded)
                
                if isUploaded == "0" {
                    
                    AppDataSwift.saveImageInDocumentDirectory(withImage: empImage, andImageName: imageName)
                    DBManager.getInstance().insertImageRecord(withUserId: userId, andImageName: imageName, andIsUploaded: isUploaded)
                    
                    
                }
                
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckInPopUpViewController") as! CheckInPopUpViewController
                vc.delegate = self
                vc.empImage = AppData.resizeImageAccordingToWidth(with: self.image!, scaledToWidth: 200.0)
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                
            }else{
                
                AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                AppDataSwift.showAlert("Info!", andMsg: "You already have checked in for your attendance today.", andViewController: self)
                
            }
            
        }else{
            
            if DBManager.getInstance().isAlreadyCheckin(withUserId: userId, andDateOf: date, andType: "checking") && !DBManager.getInstance().isAlreadyCheckOut(withUserId: userId, andDateOf: date, andType: "checking") {
                
                
                
                let now = Date()
                let seven_thirty = now.dateAt(hours: 19, minutes: 35)
                
                if now > seven_thirty{
                    
                    print("--- time Out do manual attendance...")
                    
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManualAttendancePopUpViewController") as! ManualAttendancePopUpViewController
                    
                    
                    vc.userID = userId
                    vc.type = type
                    vc.location = location
                    vc.device = "iphone"
                    vc.imei = imei
                    vc.attendanceFor = "time_out"
                    vc.employeeIMG = empImage
                    vc.delegate = self
                    
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                else
                {
                    
                    DBManager.getInstance().markAttendance(withUserId: userId, andType: type, andLocation: location, andDevice: "iphone", andIMEI: imei, andDateOf: date, andTime: time, andAttendanceFor: "time_out", andImageName: imageName, andIsUploaded: isUploaded)
                    
                    if isUploaded == "0" {
                        
                        AppDataSwift.saveImageInDocumentDirectory(withImage: empImage, andImageName: imageName)
                        DBManager.getInstance().insertImageRecord(withUserId: userId, andImageName: imageName, andIsUploaded: isUploaded)
                        
                    }
                    
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CheckOutPopUpViewController") as! CheckOutPopUpViewController
                    vc.delegate = self
                    vc.empImage = AppData.resizeImageAccordingToWidth(with: self.image!, scaledToWidth: 200.0)
                    vc.modalPresentationStyle = .overCurrentContext
                    self.present(vc, animated: true, completion: nil)
                    
                    
                }
                
            }else{
                
                AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                AppDataSwift.showAlert("Info!", andMsg: "You already have checked out for your attendance today.", andViewController: self)
                
            }
            
        }
        
        
    }
    
    
    //MARK: - CheckInPopUpViewControllerDelegate, CheckOutPopUpViewControllerDelegate, ManualAttendancePopUpViewControllerDelegate
    
    func dismissCheckInPopUpViewController() {
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    func dismissCheckOutPopUpViewController() {
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    func dismissManualAttendancePopUpViewController() {
        AppDataSwift.gotoHomeScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
    }
    
    
    
}
extension Date
{
    
    func dateAt(hours: Int, minutes: Int) -> Date
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        //get the month/day/year componentsfor today's date.
        
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}
extension FaceDetectionViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            
            image = UIImage(data: imageData)
            
//            self.afterCaptureImage.isHidden = false
//
//            self.afterCaptureImage.image = image
            
            
            let userId = "\(AppDataSwift.defaults.object(forKey: "user_id")!)"
            let imei = "\(UIDevice.current.identifierForVendor?.uuidString ?? "imei")"
            let location = "\(AppDataSwift.defaults.object(forKey: "latitude")!),\(AppDataSwift.defaults.object(forKey: "longitude")!)"
            let dateObj = Date()
            let date = AppData.getDateWithFormateString("yyyy-MM-dd", andDateObject: dateObj)
            let time = AppData.getDateWithFormateString("HH:mm:ss", andDateObject: dateObj)
            var attendanceFor = "time_in"

            if AppDataSwift.defaults.bool(forKey: "isOpenScannerForCheckIn") {
                attendanceFor = "time_in"
            }else{
                attendanceFor = "time_out"
            }

            if AppDataSwift.isWifiConnected{

                AppDataSwift.showLoader("", andViewController: self)
                self.markAttendance(withUserId: userId, withType: "checking", andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andAttendanceFor: attendanceFor, andEmployeeImage: image!, andDateObj: dateObj)

            }
            else
            {

                self.markAttendanceOffline(withUserId: userId, withType: "checking", andLocation: location, andIMEI: imei, andDate: date!, andTime: time!, andEmployeeImage: image!, andDateObj: dateObj, andIsUploaded: "0")

            }
        }
    }
}
