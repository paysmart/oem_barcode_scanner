import 'dart:async';

import 'package:flutter/services.dart';

class OEMBarcodeScanner {
  static const _channel = const MethodChannel('oem_barcode_scanner');
  static const eventChannel = const EventChannel('oem_barcode_scanner/events');

  static Future<String> scan(String color) async =>
      await _channel.invokeMethod('scan', {'color': color});
}
