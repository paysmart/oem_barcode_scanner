import 'dart:async';

import 'package:flutter/services.dart';

class OEMBarcodeScanner {
  static const _channel = const MethodChannel('oem_barcode_scanner');
  static const eventChannel = const EventChannel('oem_barcode_scanner/events');

  static Future<String> scanBarCode(String color,
      {String text = 'Posicione o código de barras sob\n a linha e aguarde a leitura'}) async =>
      await _channel.invokeMethod(
          'scanBarCode', {'color': color, 'text': text});

  static Future<String> scanQRCode(String color,
      {String text = 'Posicione o QR Code ELO na\n marcação e aguarde a leitura'}) async =>
      await _channel.invokeMethod(
          'scanQRCode', {'color': color, 'text': text});
}
