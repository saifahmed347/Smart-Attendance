//
//  ScannerViewController.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 07/06/2017.
//  Copyright © 2017 Gexton. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import AVFoundation

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var btnEmpImage: UIButton!
    @IBOutlet weak var imageViewEmpPic: UIImageView!
    
    @IBOutlet weak var labelHi: UILabel!
    
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var viewTabBar: UIView!
    
    //Code Scanner
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
//
//
//
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                              AVMetadataObject.ObjectType.code39,
                              AVMetadataObject.ObjectType.code39Mod43,
                              AVMetadataObject.ObjectType.code93,
                              AVMetadataObject.ObjectType.code128,
                              AVMetadataObject.ObjectType.ean8,
                              AVMetadataObject.ObjectType.ean13,
                              AVMetadataObject.ObjectType.aztec,
                              AVMetadataObject.ObjectType.pdf417,
                              AVMetadataObject.ObjectType.qr,
    AVMetadataObject.ObjectType.upce]
    
    var imagePicker = UIImagePickerController()
    var chosenImage = UIImage()
    
    
    /// Saif QRScanner Updation
    
    @IBOutlet weak var cameraView: UIView!

//    private var captureSessions: AVCaptureSession = AVCaptureSession()
//    private let sessionQueue = DispatchQueue(label: "Capture Session Queue")
//
//    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
//    private func setupCaptureSession() {
//        sessionQueue.sync {
//            self.captureSessions.beginConfiguration()
//
//            let output = AVCaptureMetadataOutput()
//
//            if let device = AVCaptureDevice.default(for: .video),
//                let input = try? AVCaptureDeviceInput(device: device),
//                self.captureSessions.canAddInput(input) && self.captureSessions.canAddOutput(output) {
//
//                self.captureSessions.addInput(input)
//                self.captureSessions.addOutput(output)
//
//                output.metadataObjectTypes = [
//                    .aztec,
//                    .code39,
//                    .code39Mod43,
//                    .code93,
//                    .code39Mod43,
//                    .code128,
//                    .dataMatrix,
//                    .ean8,
//                    .ean13,
//                    .interleaved2of5,
//                    .itf14,
//                    .interleaved2of5,
//                    .pdf417,
//                    .qr,
//                    .upce
//                ]
//
//                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            }
//
//            self.captureSessions.commitConfiguration()
//
//            DispatchQueue.main.async {
//                self.setupPreviewLayer(session: self.captureSessions)
//                self.setupBoundingBox()
//            }
//
//            self.captureSessions.startRunning()
//        }
//    }
    
    
    private func setupPreviewLayer(session: AVCaptureSession) {
//        previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.frame = cameraView.layer.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//
//        cameraView.layer.addSublayer(previewLayer)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.frame = cameraView.layer.bounds
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        
        cameraView.layer.addSublayer(videoPreviewLayer!)
    }

    // MARK - Bounding Box
    private var boundingBox = CAShapeLayer()
    private func setupBoundingBox() {
        boundingBox.frame = cameraView.layer.bounds
        boundingBox.strokeColor = UIColor.red.cgColor
        boundingBox.lineWidth = 2.0
        boundingBox.fillColor = UIColor.clear.cgColor

        cameraView.layer.addSublayer(boundingBox)
    }

    fileprivate func updateBoundingBox(_ points: [CGPoint]) {
        guard let firstPoint = points.first else {
            return
        }

        let path = UIBezierPath()
        path.move(to: firstPoint)

        var newPoints = points
        newPoints.removeFirst()
        newPoints.append(firstPoint)

        newPoints.forEach { path.addLine(to: $0) }

        boundingBox.path = path.cgPath
        boundingBox.isHidden = false
    }

    private var resetTimer: Timer?
    fileprivate func hideBoundingBox(after: Double) {
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval() + after,
                                          repeats: false) {
                                            [weak self] (timer) in
                                            self?.resetViews() }
    }

    private func resetViews() {
        boundingBox.isHidden = true
    }
    
    /// Saif QRScanner Updation

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setScanner()
//        self.setupCaptureSession()
    }
    
    
    //MARK: - Scanner
    
    func setScanner() {
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        //        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        self.captureSession?.beginConfiguration()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input =  try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            self.captureSession?.commitConfiguration()
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
//            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
//            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//            videoPreviewLayer?.frame = self.cameraView.layer.bounds
//            self.cameraView.layer.addSublayer(videoPreviewLayer!)
//
//            // Start video capture.
//
//            // Move the message label and top bar to the front
//            //            view.bringSubviewToFront(self.viewTopBar)
//            //            view.bringSubviewToFront(self.viewTabBar)
//
//            // Initialize QR Code Frame to highlight the QR code
//            qrCodeFrameView = UIView()
//
//            if let qrCodeFrameView = qrCodeFrameView {
//                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
//                qrCodeFrameView.layer.borderWidth = 2
//                self.cameraView.addSubview(qrCodeFrameView)
//                self.cameraView.bringSubviewToFront(qrCodeFrameView)
//            }
            
            DispatchQueue.main.async {
                self.setupPreviewLayer(session: self.captureSession!)
                self.setupBoundingBox()
            }

            
            captureSession?.startRunning()

            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
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
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopScanner()
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
    
    
    
    func startScanner() {

        if self.captureSession != nil {
            if !(self.captureSession?.isRunning)! {
                self.captureSession?.startRunning()
            }
        }

    }
    
    func stopScanner() {
        if self.captureSession != nil {
            if ((self.captureSession?.isRunning)!) {
                self.captureSession?.stopRunning()
            }
        }
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
//
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
//
//        // Check if the metadataObjects array is not nil and it contains at least one object.
//        if metadataObjects == nil || metadataObjects.count == 0 {
//            qrCodeFrameView?.frame = CGRect.zero
//            print("No QR/barcode is detected")
//            return
//        }
//
//        // Get the metadata object.
//        let metadataObj = metadataObjects.first as! AVMetadataMachineReadableCodeObject
//
//        if supportedCodeTypes.contains(metadataObj.type) {
//            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
//            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
//            qrCodeFrameView?.frame = barCodeObject!.bounds
//
//            if metadataObj.stringValue != nil {
//                print("value: \(metadataObj.stringValue!)")
//
////                AppDataSwift.gotoFaceDetectionScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
//                self.stopScanner()
//
//                if AppDataSwift.isWifiConnected {
//
//                    AppDataSwift.showLoader("", andViewController: self)
//                    self.validateQR(withQRCode: "\(metadataObj.stringValue!)")
//
//                }else{
//
//                    let QRCodeValue = "\(AppDataSwift.defaults.object(forKey: "QRCodeValue")!)"
//
//                    if QRCodeValue == "\(metadataObj.stringValue!)" {
//
//                        AppDataSwift.gotoFaceDetectionScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
//
//                    }else{
//
//                        let message = "Wrong QR code company code can't be validated."
//                        let ac = UIAlertController.init(title: "Info!", message: message, preferredStyle: .alert)
//                        let ok = UIAlertAction.init(title: "OK", style: .default, handler: { action in
//                            self.setScanner()
//                        })
//                        ac.addAction(ok)
//                        self.present(ac, animated: true, completion: nil)
//
//                    }
//
//                }
//            }
//
//        }
//    }
    
    
    // MARK: - HTTP Services
    
    func validateQR(withQRCode qrcode: String) {
        
        print("qrcode: \(qrcode)")
        let url = AppDataSwift.BASE_URL + "validateQR"
        
        print("url: \(url)")
        
        let parameters: Parameters = [
            "user_id": "\(AppDataSwift.defaults.object(forKey: "user_id")!)",
            "qrcode": qrcode
        ]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: AppDataSwift.getHTTPHeader()).responseJSON(completionHandler: { response in
            
            switch response.result {
                
            case .success(let value):
                
                let json = JSON(value)
                print("markAttendance JSON: \(json)")
                
                if json["status"].stringValue.localizedLowercase == "success" {
                    
                    //update QRCode Value
                    AppDataSwift.defaults.set(qrcode, forKey: "QRCodeValue")
                    AppDataSwift.defaults.synchronize()
                    
                    print("=== Yahooooo ")

                    AppDataSwift.dismissLoader(viewController: self)
                    
                    self.stopScanner()
                    AppDataSwift.gotoFaceDetectionScreen(withNavigationController: self.navigationController!, andIsAnimated: false)
                    
                } else if json["status"].stringValue.localizedLowercase == "error" {
                    
                    let message = json["msg"].stringValue
                    let ac = UIAlertController.init(title: "Info!", message: message, preferredStyle: .alert)
                    let ok = UIAlertAction.init(title: "OK", style: .default, handler: { action in
//                        self.setScanner()
//                        self.setupCaptureSession()
                    })
                    ac.addAction(ok)
                    self.present(ac, animated: true, completion: nil)
                }
                
            case .failure(let error):
                
                let ac = UIAlertController.init(title: "Server Error!", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction.init(title: "OK", style: .default, handler: { action in
//                    self.setScanner()
//                    self.setupCaptureSession()
                })
                ac.addAction(ok)
                self.present(ac, animated: true, completion: nil)
                
            }
            
            AppDataSwift.dismissLoader(viewController: self)
            
        })
        
    }
    


    
}
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {



            guard let transformedObject = videoPreviewLayer?.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject else {
                return
            }

            self.stopScanner()


            if AppDataSwift.isWifiConnected {

                AppDataSwift.showLoader("", andViewController: self)
                self.validateQR(withQRCode: "\(object.stringValue!)")

            }else{

                let QRCodeValue = "\(AppDataSwift.defaults.object(forKey: "QRCodeValue")!)"

                if QRCodeValue == "\(object.stringValue!)" {

                    AppDataSwift.gotoFaceDetectionScreen(withNavigationController: self.navigationController!, andIsAnimated: false)

                }else{

                    let message = "Wrong QR code company code can't be validated."
                    let ac = UIAlertController.init(title: "Info!", message: message, preferredStyle: .alert)
                    let ok = UIAlertAction.init(title: "OK", style: .default, handler: { action in
//                        self.setScanner()
//                        self.setupCaptureSession()
                    })
                    ac.addAction(ok)
                    self.present(ac, animated: true, completion: nil)

                }

            }

            updateBoundingBox(transformedObject.corners)
            hideBoundingBox(after: 0.25)
        }
    }
}

