// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_camera_segmentation/flutter_camera_segmentation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  int? _cameraId;
  Uint8List? _capturedPhotoBytes;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    initCamera();
  }

  @override
  void dispose() {
    disposeCamera();

    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initCamera();
    } else if (state == AppLifecycleState.paused) {
      disposeCamera();
    }
  }

  Future<void> initCamera() async {
    final cameraId = await FlutterCameraSegmentation.createCamera();

    setState(() {
      _cameraId = cameraId;
    });
  }

  Future<void> disposeCamera() async {
    setState(() {
      _cameraId = null;
    });

    await FlutterCameraSegmentation.disposeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _capturedPhotoBytes == null
              ? _cameraId == null
                  ? Text('Camera not initialized')
                  : Texture(textureId: _cameraId!)
              : Image.memory(_capturedPhotoBytes!),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final bytes = await FlutterCameraSegmentation.capturePhoto();
            if (bytes != null) {
              setState(() {
                _capturedPhotoBytes = bytes;
              });
            }
          },
          child: Icon(Icons.camera),
        ),
      ),
    );
  }
}
