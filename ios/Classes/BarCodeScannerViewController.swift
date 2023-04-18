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
    var text : String!
    var delegate: ScannerBarCodeDelegate? = nil
    let viewBarCode = UIView()
    let viewDigitBarCode = UIView()
    let mainView = UIView()
    var screenSize = UIScreen.main.bounds
    let labelText = UILabel()
    
    let imageString: String="iVBORw0KGgoAAAANSUhEUgAAAJMAAACXCAYAAAARdGkDAAABQ2lDQ1BJQ0MgUHJvZmlsZQAAKJFjYGASSSwoyGFhYGDIzSspCnJ3UoiIjFJgf8LAySDJwM3AzCCYmFxc4BgQ4ANUwgCjUcG3awyMIPqyLsisRTwR7WkyfL2105bP/3JFfT2mehTAlZJanAyk/wBxWnJBUQkDA2MKkK1cXlIAYncA2SJFQEcB2XNA7HQIewOInQRhHwGrCQlyBrJvANkCyRmJQDMYXwDZOklI4ulIbKi9IMDj4urjoxBgZGJo4ULAuaSDktSKEhDtnF9QWZSZnlGi4AgMpVQFz7xkPR0FIwMjAwYGUJhDVH++AQ5LRjEOhFg+DwOD2TMg4xBCLPEJA8OOOmjQQMVUgWoEgGG092dBYlEi3AGM31iK04yNIGzu7QwMrNP+//8czsDArsnA8Pf6//+/t////3cZAwPzLQaGA98A2H5g0IGwqcAAAABiZVhJZk1NACoAAAAIAAIBEgADAAAAAQABAACHaQAEAAAAAQAAACYAAAAAAAOShgAHAAAAEgAAAFCgAgAEAAAAAQAAAJOgAwAEAAAAAQAAAJcAAAAAQVNDSUkAAABTY3JlZW5zaG90pQWjhwAAAj1pVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPGV4aWY6VXNlckNvbW1lbnQ+U2NyZWVuc2hvdDwvZXhpZjpVc2VyQ29tbWVudD4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9uPjE0NzwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lvbj4xNTE8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KjWe/TQAABUpJREFUeAHt3E1oHGUcx/Hnmd1Ik/QgSAQ9iAdB6UGhghS9FLx56cVqj4Uq6NWbgrAgeNMeVFRQfDlISd1EkYAeTJpoY33HamxDazZSu93GNtlmM++78/jfWLodzDQF28kzy3dh2Xl2Jzu/5/P8mX12ZjZKcUMAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAAQQQQAABBBBAAAEEEEAAgaILVKamykfr3nOTZ73FAzN/71PG6KL3ifxbIDB2unW7MWZR7uu3TmLME5PnHtuCKGyyyALVmrdLKqhzuY6uPLwx13y8yP0ie84C1dra/ivVk17wKnPmlpzjsLlCCsh8aLzmVtL102v9cjHaVch+ETpngUrFGau5b/VKJ710ohk+n3MiNldIAWOc8draoXT59FrzK9EHfIsr5MjmHHp0tDRWa33aK5300nwznJDPPSfnVGyucALdQlpY+yxdPr3WqdVocu+oKRWuXwTOWUD2NtfaI51uRkd2ywHLnFOxucIJyGT7WnOkX5eDr3dPGQqpcAObd2D5+i97pDd7H2bppdnz/iyFlPegFHR71QX3xXT59Fqfn3G/e/DtHwYK2jVi5ylQrbWe7JVOeunwQuvk3e/VtuWZp9+31bdnxD/5s7Vjz13b5zYawLrXVnLkWw0NaDVcdtbvg2Xty7q+gLhGKU8pEyilPaVVoBLjK0cHWsk6RoVJ9zUjz8uj1iqS9QJjVKy0CbV2IpN0opJ2wo5RbUebyDil2CRK7nH75KU4PvRH5/jRPSOtjbLxnGUCr54xg7If8tL7IntacxeihywjuyFx+vLg3P6R5KDoDN4QoZvwJjtu689pWl8WU8lRt96EGuAtNxHoy2L6eGH5ael3vEnft+zl2qq10f6XSV8eqDtw30jr3rr78CN3DH2/kc5Zt62OLQVq+8C/k++hslbbyjqUCbarTBIordcn4Vom2Vprz+j1Cbcvk/FQJtu+SZJIlj1H6zCRCblMxiM5MRw63cm443TbsVykKc912youO6WoY9ptufIuPrUct1/5LTyxUS6es1hgpu4+lTXtPnh8mUMDFo+djdH0TMN/Oaug3p+/xEFLG0fN2kxyOuWrhv9uVkGN11qcTrF28GwMVjHOdN2rZhWU/KyJE702jpu1meRapum6O5FVUN8u+VyCYu3gWRhs7+YFxcVxFo6btZG6BTVT98az9lDHGv6Eko9FaztAMMsEpFikoD7KKqhvGv47/KDAsjGzOo5cfTl9znsts6DOB89YnZ9wlgnIYYMjdf+FrIKaXQrusSwxcWwXmGl4+zIKapGfPdk+ehbm+7Lu7pSC+s8/rnj99+ZOC+NaGYlvLZeH5dE7h3/64q/VEWnOXz1SPy5FD1zdZhmB6xYYNabkdjrPXgw6Ky/9vHL4/g8bw9f9x6yIAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCAAAIIIIAAAggggAACCCCQk8A/DBFuOZQNwX8AAAAASUVORK5CYII="

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
        view.setImage(arrowImage(), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.addTarget(self, action: #selector(backToScreen), for: .touchUpInside)
        return view
    }()
    
    func arrowImage() -> UIImage!{
        let dataDecoded : Data = Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelText.text = "Posicione o código de barras/QR ELO sob \n a linha e aguarde a leitura"
        labelText.textColor = UIColor.white
        labelText.translatesAutoresizingMaskIntoConstraints = false
        labelText.numberOfLines = 2
        labelText.textAlignment = .center
        
        view.frame = CGRect(x: 0, y: 0, width: screenSize.height, height: screenSize.width)
        mainView.frame = CGRect(x: 0, y: 0, width: screenSize.height, height: screenSize.width)
        
        avCaptureSession = AVCaptureSession()
        DispatchQueue.main.async() { [self] in
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                self.requestManualInput()
                return
            }
            let avVideoInput: AVCaptureDeviceInput

            do {
                avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                self.requestManualInput()
                return
            }

            if (self.avCaptureSession.canAddInput(avVideoInput)) {
                self.avCaptureSession.addInput(avVideoInput)
            } else {
                self.requestManualInput()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                self.avCaptureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.interleaved2of5]
            } else {
                self.requestManualInput()
                return
            }

            self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)

            self.avPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            self.avPreviewLayer.frame = self.view.layer.bounds
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.avPreviewLayer.layoutSublayers()
            self.avPreviewLayer.layoutIfNeeded()
            self.avCaptureSession.startRunning()
            self.view.addSubview(self.mainView)
            
            self.view.layer.addSublayer(self.avPreviewLayer)
            self.view.bringSubviewToFront(self.mainView)
            self.view.bringSubviewToFront(self.bottomView)
            self.view.bringSubviewToFront(self.topView)
            self.view.bringSubviewToFront(self.lineView)
            self.view.bringSubviewToFront(self.labelText)
            self.mainView.layoutIfNeeded()
            self.mainView.layoutSubviews()
            self.mainView.setNeedsUpdateConstraints()
            self.view.bringSubviewToFront(self.digitBarCodeButton)
            self.view.bringSubviewToFront(self.backButton)

            self.setConstraintsForControls()
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
        
        lineView.widthAnchor.constraint(equalToConstant: screenSize.height).isActive = true
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
        return .landscape
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .landscapeLeft
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
