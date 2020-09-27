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

class BarCodeScannerViewController: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    var color : String!
    var delegate: ScannerBarCodeDelegate? = nil
    let viewBarCode = UIView()
    let viewDigitBarCode = UIView()
    let mainView = UIView()
    var screenSize = UIScreen.main.bounds
    let labelText = UILabel()

    private lazy var bottomView : UIView! = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#262626")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var lineView : UIView! = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#CD0000")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var topView : UIView! = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#262626")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var digitBarCodeButton: UIButton! = {
        let view = UIButton()
        view.setTitle("Digitar código de barras", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = hexStringToUIColor(hex: color)
        view.layer.cornerRadius = 15
        view.addTarget(self, action: #selector(requestManualInput), for: .touchUpInside)
        return view
    }()
    
    public lazy var backButton: UIButton! = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "arrow.png"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.addTarget(self, action: #selector(backToScreen), for: .touchUpInside)
        return view
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelText.text = "Posicione o código de barras sob \n a linha e aguarde a leitura"
        labelText.textColor = UIColor.white
        labelText.translatesAutoresizingMaskIntoConstraints = false
        labelText.numberOfLines = 2
        labelText.textAlignment = .center
        
        view.frame = CGRect(x: 0, y: 0, width: screenSize.height, height: screenSize.width)
        mainView.frame = CGRect(x: 0, y: 0, width: screenSize.height, height: screenSize.width)
        
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

            self.avPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            self.avPreviewLayer.frame = self.view.layer.bounds
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.avPreviewLayer.layoutSublayers()
            self.avPreviewLayer.layoutIfNeeded()
            self.avCaptureSession.startRunning()
            self.view.addSubview(mainView)
            
            self.view.layer.addSublayer(self.avPreviewLayer)
            self.view.bringSubviewToFront(mainView)
            self.view.bringSubviewToFront(bottomView)
            self.view.bringSubviewToFront(topView)
            self.view.bringSubviewToFront(lineView)
            self.view.bringSubviewToFront(labelText)
            mainView.layoutIfNeeded()
            mainView.layoutSubviews()
            mainView.setNeedsUpdateConstraints()
            self.view.bringSubviewToFront(digitBarCodeButton)
            self.view.bringSubviewToFront(backButton)

            setConstraintsForControls()
        }
    }
    
    private func setConstraintsForControls() {
        self.view.addSubview(bottomView)
        self.view.addSubview(topView)
        self.view.addSubview(lineView)
        self.view.addSubview(digitBarCodeButton)
        self.view.addSubview(backButton)
        self.view.addSubview(labelText)
        
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:0).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:0).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 90.0).isActive=true

        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:0).isActive = true
        topView.topAnchor.constraint(equalTo: view.topAnchor, constant:0).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:0).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 90).isActive=true
        
        digitBarCodeButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        digitBarCodeButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        digitBarCodeButton.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant: -20).isActive=true
        digitBarCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:20).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        backButton.topAnchor.constraint(equalTo:view.topAnchor,constant: 10).isActive=true
        
        labelText.widthAnchor.constraint(equalToConstant: 400).isActive = true
        labelText.heightAnchor.constraint(equalToConstant: 100).isActive = true
        labelText.topAnchor.constraint(equalTo:view.topAnchor,constant: 0).isActive=true
        labelText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        lineView.widthAnchor.constraint(equalToConstant: 1000).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lineView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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

    @objc func requestManualInput() {
        delegate?.requestManualInput()
        dismiss(animated: true)
    }
    
    @objc func backToScreen(){
        dismiss(animated: true)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
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
