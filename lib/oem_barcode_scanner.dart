
import 'dart:async';

import 'package:flutter/services.dart';

class OemBarcodeScanner {
  static const MethodChannel _channel =
      const MethodChannel('oem_barcode_scanner');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
