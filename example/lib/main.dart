// ignore_for_file: prefer_const_constructors

import 'dart:async';

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

class _MyAppState extends State<MyApp> {
  int? _cameraId;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameraId = await FlutterCameraSegmentation.createCamera();

    setState(() {
      _cameraId = cameraId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _cameraId == null
              ? Text('Camera not initialized')
              : Texture(textureId: _cameraId!),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            FlutterCameraSegmentation.startCamera();
          },
          child: Icon(Icons.camera),
        ),
      ),
    );
  }
}
