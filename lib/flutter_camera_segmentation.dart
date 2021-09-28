import 'dart:async';

import 'package:flutter/services.dart';

class FlutterCameraSegmentation {
  static const MethodChannel _channel =
      MethodChannel('flutter_camera_segmentation');

  static Future<String?> testDeepLab() async {
    await _channel.invokeMethod('testDeepLab');
  }

  static Future<int> createCamera() async {
    final cameraId = await _channel.invokeMethod('createCamera');
    return cameraId;
  }

  static Future<void> startCamera() async {
    await _channel.invokeMethod('startCamera');
  }
}
