#import "OemBarcodeScannerPlugin.h"
#if __has_include(<oem_barcode_scanner/oem_barcode_scanner-Swift.h>)
#import <oem_barcode_scanner/oem_barcode_scanner-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "oem_barcode_scanner-Swift.h"
#endif

@implementation OemBarcodeScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOemBarcodeScannerPlugin registerWithRegistrar:registrar];
}
@end
