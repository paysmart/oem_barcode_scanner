import Flutter
import UIKit

public class SwiftOemBarcodeScannerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, ScannerBarCodeDelegate
{
    private static var scannerViewController = UIViewController()
    static var barCodeStream:FlutterEventSink?=nil
    let barCodeScannerViewController = BarCodeScannerViewController()
    
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "oem_barcode_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftOemBarcodeScannerPlugin()
    scannerViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
    
    let eventChannel = FlutterEventChannel(name: "oem_barcode_scanner/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if ("scan" == call.method) {
        if let args = call.arguments as? [String: Any]{
            barCodeScannerViewController.color = args["color"] as? String
        }
        showBarCode()
    }
    
  }
    
    private func showBarCode(){
        barCodeScannerViewController.delegate = self
        
        if #available(iOS 13.0, *) {
            barCodeScannerViewController.modalPresentationStyle = .fullScreen
        }
        SwiftOemBarcodeScannerPlugin.scannerViewController.present(barCodeScannerViewController, animated: true, completion: nil)
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
    
    func requestManualInput() {
        SwiftOemBarcodeScannerPlugin.barCodeStream!("user_manual_input")
    }

}


