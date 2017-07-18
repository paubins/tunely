//
//  CameraViewController.swift
//  Stutter
//
//  Created by Patrick Aubin on 6/9/17.
//  Copyright © 2017 com.paubins.Stutter. All rights reserved.
//

import Foundation
import SwiftyCam
import SwiftyButton
import AVFoundation
import Beethoven
import Pitchy
import Hue
import LLSpinner
import RecordButton
import ReplayKit
import AMPopTip
import SwiftyStoreKit
import Photos
import CocoaLumberjack

class CameraViewController : SwiftyCamViewController {
    
    var buttonTimer:Timer!
    var recordButton:SDevCircleButton!
    var exporter:AVAssetExportSession!
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        var config = Config(estimationStrategy: .yin)
        let pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine.levelThreshold = -30.0
        
        return pitchEngine
        }()
    
    var button1:SDevCircleButton! = nil
    
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    var actualRecordButton:RecordingButton!
    
    var firstTime:Bool = true
    var horizontalHeightAnchor:NSLayoutConstraint!
    
    let screenRecorder:JKScreenRecorder = JKScreenRecorder()
    
    var touchController:DazTouchController!
    var horizontalContactsController:MEVHorizontalContactsExample1 = MEVHorizontalContactsExample1(frame: .zero)
    
    var stopped:Bool = false
    
    var checkbox:UIView = {
        let snapCheckbox = SnapchatCheckbox(frame: .zero)
        snapCheckbox.translatesAutoresizingMaskIntoConstraints = false
        snapCheckbox.addTarget(self, action: #selector(checkedBox), for: .touchUpInside)
        
        let containerView:UIView = UIView(frame: .zero)
        containerView.addSubview(snapCheckbox)
        containerView.isUserInteractionEnabled = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let label:UILabel = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Unchecked"
        containerView.addSubview(label)
        
        snapCheckbox.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        snapCheckbox.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        snapCheckbox.widthAnchor.constraint(equalToConstant: 30).isActive = true
        snapCheckbox.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: snapCheckbox.rightAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        return containerView
    }()
    
    var flipCameraButton:UIView = {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        var flipCameraButton = PressableButton()
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(flipCameraButton)
        
        flipCameraButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        flipCameraButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        flipCameraButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        flipCameraButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        flipCameraButton.translatesAutoresizingMaskIntoConstraints = false
        flipCameraButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                        shadow: UIColor.black)
        flipCameraButton.shadowHeight = 10
        flipCameraButton.cornerRadius = 15
        flipCameraButton.setTitle("Flip", for: .normal)
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        
        return containerView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        videoGravity = .resizeAspectFill
        defaultCamera = .front
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLogInfo("opened camera view")
        
        self.checkbox.isHidden = false
        
        self.touchController = DazTouchController()
        
        self.view.addSubview(self.touchController.view)
        
        self.touchController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.touchController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.touchController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.touchController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.pinchToZoom = false
        self.swipeToZoom = true
        self.swipeToZoomInverted = true
        
        self.videoGravity = .resizeAspectFill
        
        self.button1 = SDevCircleButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        self.view.addSubview(self.button1)
        
        let longPressGestureRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordButtonWasTapped))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        longPressGestureRecognizer.delegate = self
        self.panGesture.delegate = self
        
        button1.addGestureRecognizer(longPressGestureRecognizer)
        //        button1.addGestureRecognizer(self.panGesture)
        
        button1.setTitleColor(UIColor(white: 1, alpha: 1.0), for: UIControlState.normal)
        button1.setTitleColor(UIColor(white: 1, alpha: 1.0), for: UIControlState.selected)
        button1.setTitleColor(UIColor(white: 1, alpha: 1.0), for: UIControlState.highlighted)
        
        button1.setTitle("", for: UIControlState.normal)
        button1.setTitle("", for: UIControlState.selected)
        button1.setTitle("", for: UIControlState.highlighted)
        
        button1.backgroundColor = UIColor.red
        
        button1.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80).isActive = true
        button1.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        button1.heightAnchor.constraint(equalToConstant: 80).isActive = true
        button1.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.recordButton = button1
        
        self.view.backgroundColor = UIColor.black
        
        let showEffectsButton:PressableButton = PressableButton(frame: .zero)
        showEffectsButton.translatesAutoresizingMaskIntoConstraints = false
        showEffectsButton.colors = .init(button: UIColor(rgbColorCodeRed: 76, green: 76, blue: 147, alpha: 1.0),
                                        shadow: UIColor.black)
        showEffectsButton.shadowHeight = 10
        
        self.view.addSubview(showEffectsButton)
        self.view.addSubview(self.flipCameraButton)
        self.view.addSubview(self.horizontalContactsController)
        //self.view.addSubview(self.checkbox)
        
        self.horizontalContactsController.isHidden = false
        
        //self.checkbox.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        //self.checkbox.bottomAnchor.constraint(equalTo: self.horizontalContactsController.topAnchor).isActive = true
        //self.checkbox.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        showEffectsButton.setTitle("Effects", for: .normal)
        showEffectsButton.addTarget(self, action: #selector(showHideEffects), for: .touchUpInside)
        showEffectsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        showEffectsButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        showEffectsButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        showEffectsButton.bottomAnchor.constraint(equalTo: self.horizontalContactsController.topAnchor).isActive = true
        
        showEffectsButton.isHidden = true
        
        self.horizontalContactsController.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.horizontalContactsController.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.horizontalContactsController.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.horizontalHeightAnchor = self.horizontalContactsController.heightAnchor.constraint(equalToConstant: 0)
        self.horizontalHeightAnchor.isActive = true
        
        self.flipCameraButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.flipCameraButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        
        self.flipCameraButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        self.flipCameraButton.widthAnchor.constraint(equalToConstant: 90).isActive = true

        self.actualRecordButton = RecordingButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        self.actualRecordButton.recordingDuration = 60
        self.actualRecordButton.delegate = self
        
        self.view.addSubview(self.actualRecordButton)
    
        self.actualRecordButton.translatesAutoresizingMaskIntoConstraints = false
        self.actualRecordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.actualRecordButton.bottomAnchor.constraint(equalTo: self.horizontalContactsController.topAnchor, constant: -40).isActive = true
        self.actualRecordButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.actualRecordButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
//        self.actualRecordButton.buttonColor = UIColor.red
        
        self.actualRecordButton.addTarget(self, action: #selector(record), for: .touchUpInside)
        
        self.allowBackgroundAudio = true
        self.lowLightBoost = true
        self.doubleTapCameraSwitch = true
        self.pinchToZoom = true
        
        self.cameraDelegate = self
        self.shouldUseDeviceOrientation = true
    }
    
    let popTips:[PopTip] = {
        var allPoptips:[PopTip] = []
        let popTip = PopTip()
        
        allPoptips.append(popTip)

        let popTip2 = PopTip()

        allPoptips.append(popTip2)
        
        let popTip3 = PopTip()

        allPoptips.append(popTip2)
        
        return allPoptips
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pitchEngine.start()
        if (self.firstTime) {
            self.popTips.first?.show(text: "Tap me to start recording!", direction: .up,
                                     maxWidth: 200, in: view, from: self.actualRecordButton.frame)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pitchEngine.stop()
        self.button1.backgroundColor = UIColor.red
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LLSpinner.stop()
    }
    
    func showHideEffects() {
        UIView.animate(withDuration: 1) {
            if ( self.horizontalHeightAnchor.constant == 0) {
                self.horizontalHeightAnchor.constant = 80
            } else {
                self.horizontalHeightAnchor.constant = 0
            }
        }
    }
    
    func checkedBox() {
        print("checked")
    }
    
    func flipCamera() {
        self.switchCamera()
    }
    
    func record() {
        DDLogInfo("record button tapped")
        if (screenRecorder.recording) {
            print("stopped")
            // self.feedbackButton.isHidden = false
            self.flipCameraButton.isHidden = false
            
            if (!self.stopped) {
                self.actualRecordButton.stopRecord()
            }
            
            self.stopped = false
            
            self.stop()
            self.checkPhotoLibraryPermission()
            
            self.screenRecorder.stopRecording { (viewController, videoPath, error) in
                if ((videoPath) != nil) {
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath!, self, nil, nil)
                }
                
                LLSpinner.stop()
                viewController?.modalPresentationStyle = .fullScreen
                
                self.present(viewController!, animated: true, completion: {
                    DDLogInfo("showed completed recording")
                })
            }
            
            LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 0.6))
        } else {
            for popTip in self.popTips {
                popTip.hide()
            }
            self.actualRecordButton.record()
            self.flipCameraButton.isHidden = true
            
            self.screenRecorder.startRecording { (error) in
                print(error?.localizedDescription ?? "error")
                self.actualRecordButton.endProgressValue = 0.0
            }
        }
    }
    
    func checkPhotoLibraryPermission() {
        DDLogInfo("check photo library permissions")
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: break
        //handle authorized status
        case .denied, .restricted : break
        //handle denied status
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized: break
                // as above
                case .denied, .restricted: break
                // as above
                case .notDetermined: break
                    // won't happen but still
                }
            }
        }
    }

    
    func stop() {
        self.stopVideoRecording()
    }
    
    func recordButtonWasTapped(sender: UILongPressGestureRecognizer) {

    }
    
    func makePurchase() {
        SwiftyStoreKit.purchaseProduct("com.paubins.Video-Tuner.1", quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
    }
    
    func offsetColor(_ offsetPercentage: Double) -> UIColor {
        let color: UIColor
        
        switch abs(offsetPercentage) {
        case 0...5:
            color = UIColor(hex: "3DAFAE")
        case 6...25:
            color = UIColor(hex: "FDFFB1")
        default:
            color = UIColor(hex: "E13C6C")
        }
        
        return color
    }
}

extension CameraViewController: PitchEngineDelegate {
    
    func pitchEngineDidReceivePitch(_ pitchEngine: PitchEngine, pitch: Pitch) {
        let offsetPercentage = pitch.closestOffset.percentage
        let absOffsetPercentage = abs(offsetPercentage)
        
        self.recordButton.setTitle(pitch.note.string, for: UIControlState.normal)
        
        guard absOffsetPercentage > 1.0 else {
            return
        }
        
        let color = offsetColor(offsetPercentage)
        
        if(self.screenRecorder.recording) {
            self.recordButton.triggerAnimateTap()
            self.recordButton.backgroundColor = color
            self.touchController.touch(atPosition: self.recordButton.frame.origin)
            
            for popTip in self.popTips {
                popTip.hide()
            }
            
        } else {
            if (self.firstTime) {
                self.popTips[2].show(text: "This will show the note you're singing and change colors!", direction: .down, maxWidth: 200, in: view, from: self.button1.frame)
                
                self.firstTime = false
            }
            self.recordButton.triggerAnimateTap()
        }
    }
    
    func pitchEngineDidReceiveError(_ pitchEngine: PitchEngine, error: Error) {
        print(error)
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below level threshold")
        self.recordButton.setTitle("", for: UIControlState.normal)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func reset() {
        
    }
    
    func export(asset: AVAsset) throws {
        self.exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        
        let filename = "composition.mp4"
        let outputPath = NSTemporaryDirectory().appending(filename)
        
        //Check if file already exists and delete it if needed
        let fileUrl = URL(fileURLWithPath: outputPath)
        
        let manager = FileManager.default
        if manager.fileExists(atPath: outputPath) {
            var _: NSError? = nil
            try manager.removeItem(atPath: outputPath)
        }
        
        self.exporter.outputFileType = AVFileTypeMPEG4
        self.exporter.outputURL = fileUrl
        
        self.exporter.exportAsynchronously(completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: {
                if self.exporter.status == AVAssetExportSessionStatus.completed {
                    UISaveVideoAtPathToSavedPhotosAlbum(outputPath, self, nil, nil)
                    print("Success")
                    
                    let exportViewController:ExportViewController = ExportViewController()
                    exportViewController.videoPlayerView.player.setURL(fileUrl)
                    
                    self.navigationController?.pushViewController(exportViewController, animated: true)
                }
                else {
                    print(self.exporter.error?.localizedDescription ?? "error")
                    //The requested URL was not found on this server.
                }
            })
        })
    }

}


extension CameraViewController : SwiftyCamViewControllerDelegate {
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Called when takePhoto() is called or if a SwiftyCamButton initiates a tap gesture
        // Returns a UIImage captured from the current session
        print("photo")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when startVideoRecording() is called
        // Called if a SwiftyCamButton begins a long press gesture
        print("started recording")
        
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Called when stopVideoRecording() is called
        // Called if a SwiftyCamButton ends a long press gesture
        print("finished recording")
        
        LLSpinner.spin(style: .whiteLarge, backgroundColor: UIColor(white: 0, alpha: 1.0)) {

        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Called when stopVideoRecording() is called and the video is finished processing
        // Returns a URL in the temporary directory where video is stored
        print("did finish recording")
        
        do {
            try self.export(asset: AVAsset(url: url))
        } catch {
            
        }
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Called when a user initiates a tap gesture on the preview layer
        // Will only be called if tapToFocus = true
        // Returns a CGPoint of the tap location on the preview layer
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Called when a user initiates a pinch gesture on the preview layer
        // Will only be called if pinchToZoomn = true
        // Returns a CGFloat of the current zoom level
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // Called when user switches between cameras
        // Returns current camera selection
    }
}

extension CameraViewController : RecordingButtonDelegate {
    // RecordingButtonDelegate Methods
    func didStartCapture() {
        // call when capturing starts.
    }
    
    func didEndCapture() {
        self.stopped = true
        self.record()
    }
}
