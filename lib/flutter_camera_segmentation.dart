import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class FlutterCameraSegmentation {
  static const MethodChannel _channel =
      MethodChannel('flutter_camera_segmentation');

  static Future<int> createCamera() async {
    final cameraId = await _channel.invokeMethod('createCamera') as int;
    return cameraId;
  }

  static Future<void> disposeCamera() async {
    await _channel.invokeMethod('disposeCamera');
  }

  static Future<Uint8List?> capturePhoto() async {
    final bytes = await _channel.invokeListMethod<int>('capturePhoto');
    if (bytes == null) {
      return null;
    }

    return Uint8List.fromList(bytes);
  }
}
