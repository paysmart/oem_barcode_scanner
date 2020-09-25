//
//  BarCodeScannerViewController.swift
//  oem_barcode_scanner
//
//  Created by Natasha Flores on 9/24/20.
//

import UIKit
import AVFoundation

protocol ScannerBarCodeDelegate {
    func userDidScanWith(barCode: String)
    func requestManualInput()
}

final class ViewControllerScreen : UIView{
    override init(frame: CGRect = .zero){
        super.init(frame: frame)
        
        let viewDigitBarCode = UIView(frame: .zero)
        viewDigitBarCode.backgroundColor = .black
        viewDigitBarCode.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(viewDigitBarCode)
        
        viewDigitBarCode.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        viewDigitBarCode.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 15).isActive = true
        viewDigitBarCode.heightAnchor.constraint(equalToConstant: 70).isActive = true
        viewDigitBarCode.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 15).isActive = true
        
        let button = UIButton(frame: .zero)
        button.backgroundColor = .blue
        button.setTitle("Digitar código de barras", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        viewDigitBarCode.addSubview(button)
        
        backgroundColor = .darkGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BarCodeScannerViewController: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    var color : String!
    let screen = ViewControllerScreen()
    var delegate: ScannerBarCodeDelegate? = nil
    let viewBarCode = UIView()
    let viewDigitBarCode = UIView()
    let mainView = UIView()
    var screenSize = UIScreen.main.bounds

    private lazy var bottomView : UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var topView : UIView! = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var digitBarCodeButton: UIButton! = {
        let view = UIButton()
        view.setTitle("Digitar código de barras", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = hexStringToUIColor(hex: color)
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewBarCode.backgroundColor = .black
        viewDigitBarCode.backgroundColor = .black
        
        mainView.frame = CGRect(x: 0, y: 0, width: (screenSize.height * 0.8), height: 100)
        
        avCaptureSession = AVCaptureSession()
        DispatchQueue.main.async() { [self] in
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                requestManualInput()
                return
            }
            let avVideoInput: AVCaptureDeviceInput

            do {
                avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                requestManualInput()
                return
            }

            if (self.avCaptureSession.canAddInput(avVideoInput)) {
                self.avCaptureSession.addInput(avVideoInput)
            } else {
                requestManualInput()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                self.avCaptureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.interleaved2of5]
            } else {
                requestManualInput()
                return
            }

            self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)

            self.avPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            self.avPreviewLayer.frame = self.view.layer.bounds
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.avPreviewLayer.layoutSublayers()
            self.avPreviewLayer.layoutIfNeeded()
            self.view.layer.addSublayer(self.avPreviewLayer)
            
            self.avCaptureSession.startRunning()
            self.view.addSubview(mainView)
            self.view.bringSubviewToFront(mainView)
            self.view.bringSubviewToFront(bottomView)
            self.view.bringSubviewToFront(topView)
            mainView.layoutIfNeeded()
            mainView.layoutSubviews()
            mainView.setNeedsUpdateConstraints()
            self.view.bringSubviewToFront(digitBarCodeButton)
            setConstraintsForControls()
        }
    }
    
    private func setConstraintsForControls() {
        self.view.addSubview(bottomView)
        self.view.addSubview(topView)
        self.view.addSubview(digitBarCodeButton)
        
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:0).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 70.0).isActive=true
        
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:100).isActive = true
        topView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:100).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:100).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 70.0).isActive=true
        
        digitBarCodeButton.translatesAutoresizingMaskIntoConstraints = false
        digitBarCodeButton.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        digitBarCodeButton.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        digitBarCodeButton.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant: 0).isActive=true
        digitBarCodeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:100).isActive = true
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

    func checkCameraAvailability()->Bool{
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func checkForCameraPermission()->Bool{
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    func requestManualInput() {
        delegate?.requestManualInput()
        dismiss(animated: true)
    }

//    @IBAction func codeBar(_ sender: UIButton) {
//        result("user_manual_input")
//    }
//
//    @IBAction func backToScreen(_ sender: Any) {
//        if let nav = self.navigationController {
//            nav.popViewController(animated: true)
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
}
extension BarCodeScannerViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        avCaptureSession.stopRunning()
    
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.userDidScanWith(barCode: stringValue)
        }
    
        dismiss(animated: true)
    }
}
