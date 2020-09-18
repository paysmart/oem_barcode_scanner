import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var controller : FlutterViewController?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    guard let flutterViewController  = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
    let flutterChannel = FlutterMethodChannel.init(name: "oem_barcode_scanner", binaryMessenger: flutterViewController as! FlutterBinaryMessenger);
        flutterChannel.setMethodCallHandler { (flutterMethodCall, flutterResult) in
            if flutterMethodCall.method == "scan" {
                    self.window?.rootViewController = nil
                
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "BarCodeScannerViewController") as! BarCodeScannerViewController
                
                if let args = flutterMethodCall.arguments as? [String: Any]{
                        viewController.color = args["color"] as? String
                }
                
                viewController.result = flutterResult
                
                let navigationController = UINavigationController(rootViewController: flutterViewController)
                    
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.makeKeyAndVisible()
                    self.window.rootViewController = navigationController
                    navigationController.isNavigationBarHidden = true
                    navigationController.pushViewController(viewController, animated: true)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}
