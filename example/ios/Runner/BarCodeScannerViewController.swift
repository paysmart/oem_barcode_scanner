//
//  ScannerCodeViewController.swift
//  Runner
//
//  Created by Natasha Zettler on 17/09/20.
//

    import UIKit
    import AVFoundation
     
    class BarCodeScannerViewController: UIViewController {
        
        var avCaptureSession: AVCaptureSession!
        var avPreviewLayer: AVCaptureVideoPreviewLayer!
        var result : FlutterResult!
        var color : String!
        @IBOutlet weak var barCode: UIButton!
        @IBOutlet weak var back: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.barCode.backgroundColor = hexStringToUIColor(hex: color)
            avCaptureSession = AVCaptureSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                    self.failed()
                    return
                }
                let avVideoInput: AVCaptureDeviceInput
                
                do {
                    avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                } catch {
                    self.failed()
                    return
                }
                
                if (self.avCaptureSession.canAddInput(avVideoInput)) {
                    self.avCaptureSession.addInput(avVideoInput)
                } else {
                    self.failed()
                    return
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                
                if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                    self.avCaptureSession.addOutput(metadataOutput)
                    
                    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.interleaved2of5]
                } else {
                    self.failed()
                    return
                }
                
                self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
                self.avPreviewLayer.frame = self.view.layer.bounds
                self.avPreviewLayer.videoGravity = .resizeAspectFill
                self.view.layer.addSublayer(self.avPreviewLayer)
                self.avCaptureSession.startRunning()
            }
        }
        
        
        func failed() {
            let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            avCaptureSession = nil
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if (avCaptureSession?.isRunning == false) {
                avCaptureSession.startRunning()
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            if (avCaptureSession?.isRunning == true) {
                avCaptureSession.stopRunning()
            }
        }
        
        override var prefersStatusBarHidden: Bool {
            return true
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .portrait
        }
        
        func hexStringToUIColor (hex:String) -> UIColor {
            var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }

            if ((cString.count) != 6) {
                return UIColor.gray
            }

            var rgbValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
        
        @IBAction func backToScreen(_ sender: Any) {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    extension BarCodeScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            avCaptureSession.stopRunning()
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                result(stringValue)
            }
            
            dismiss(animated: true)
        }
    }
