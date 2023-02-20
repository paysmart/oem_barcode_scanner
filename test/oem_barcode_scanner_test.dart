import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    /*
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });*/
  });

  tearDown(() {
    //channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await OemBarcodeScanner.platformVersion, '42');
  });
}
