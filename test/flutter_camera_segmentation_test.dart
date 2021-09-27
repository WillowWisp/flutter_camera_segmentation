import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_camera_segmentation/flutter_camera_segmentation.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_camera_segmentation');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterCameraSegmentation.testDeepLab(), 'Deeplab loaded');
  });
}
