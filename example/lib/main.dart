import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oem_barcode_scanner/oem_barcode_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<dynamic> _eventStream;

  Widget scanResult = CircularProgressIndicator();

  @override
  void initState() {
    super.initState();

    _eventStream =
        OEMBarcodeScanner.eventChannel.receiveBroadcastStream().listen((event) {
      if (event != 'user_manual_input') {
        setState(() {
          scanResult = Text(event);
        });
      } else {
        setState(() {
          scanResult = Text(event);
        });
      }
    });
    //initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    _eventStream.cancel();
  }

  Future<void> initPlatformState() async {
    try {} on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            scanResult,
            SizedBox(
              width: 100,
            ),
            ElevatedButton(
              child: Text('Scan Barcode'),
              onPressed: () {
                OEMBarcodeScanner.scanBarCode('#28B4E7');
              },
            ),
            ElevatedButton(
              child: Text('Scan QR Code'),
              onPressed: () {
                OEMBarcodeScanner.scanQRCode('#28B4E7');
              },
            )
          ],
        ),
      ),
    );
  }
}
