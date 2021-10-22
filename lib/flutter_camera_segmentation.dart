import 'dart:async';
import 'dart:typed_data';

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

  static Future<Uint8List?> capturePhoto() async {
    final bytes = await _channel.invokeListMethod<int>('capturePhoto');
    if (bytes == null) {
      return null;
    }

    return Uint8List.fromList(bytes);
  }
}
