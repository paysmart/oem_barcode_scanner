import Flutter
import UIKit

public class SwiftOemBarcodeScannerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, ScannerBarCodeDelegate, ScannerQRCodeDelegate
{
    private static var scannerViewController = UIViewController()
    static var barCodeStream:FlutterEventSink?=nil
    let barCodeScannerViewController = BarCodeScannerViewController()
    let qrCodeScannerViewController = QRCodeScannerViewController()
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "oem_barcode_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftOemBarcodeScannerPlugin()
    scannerViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
    
    let eventChannel = FlutterEventChannel(name: "oem_barcode_scanner/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    if ("scanBarCode" == call.method) {
        if let args = call.arguments as? [String: Any]{
            barCodeScannerViewController.color = args["color"] as? String
            barCodeScannerViewController.text = args["text"] as? String
        }

        showBarCode()
    }else if ("scanQRCode" == call.method) {
        if let args = call.arguments as? [String: Any]{
            qrCodeScannerViewController.color = args["color"] as? String
            qrCodeScannerViewController.text = args["text"] as? String

        }
        showQRCode()
    }
    
  }
    
    private func showBarCode(){
        barCodeScannerViewController.delegate = self
        
        if #available(iOS 13.0, *) {
            barCodeScannerViewController.modalPresentationStyle = .fullScreen
        }
        SwiftOemBarcodeScannerPlugin.scannerViewController.present(barCodeScannerViewController, animated: true, completion: nil)
    }
    
    private func showQRCode(){
        qrCodeScannerViewController.delegate = self
        
        if #available(iOS 13.0, *) {
            qrCodeScannerViewController.modalPresentationStyle = .fullScreen
        }
        SwiftOemBarcodeScannerPlugin.scannerViewController.present(qrCodeScannerViewController, animated: true, completion: nil)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        SwiftOemBarcodeScannerPlugin.barCodeStream = events
       
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        SwiftOemBarcodeScannerPlugin.barCodeStream = nil
        return nil
    }
    
    func userDidScanWith(barCode: String) {
        SwiftOemBarcodeScannerPlugin.barCodeStream!(barCode)
    }
    
    func userDidScanWith(qrCode: String) {
        SwiftOemBarcodeScannerPlugin.barCodeStream!(qrCode)
    }
    
    func requestManualInput() {
        SwiftOemBarcodeScannerPlugin.barCodeStream!("user_manual_input")
    }

}
