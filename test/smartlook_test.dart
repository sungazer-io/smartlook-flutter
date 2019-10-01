import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartlook/smartlook.dart';

void main() {
  const MethodChannel channel = MethodChannel('smartlook');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Smartlook.platformVersion, '42');
  });
}
