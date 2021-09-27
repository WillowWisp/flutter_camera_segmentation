import Flutter
import UIKit
import Vision
import CoreML

public class SwiftFlutterCameraSegmentationPlugin: NSObject, FlutterPlugin {
    var textureRegistry: FlutterTextureRegistry
    
    init(textureRegistry: FlutterTextureRegistry) {
        self.textureRegistry = textureRegistry
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_camera_segmentation", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCameraSegmentationPlugin(
            textureRegistry: registrar.textures()
        )
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "testDeepLab" {
            let deepLab = try! DeepLabV3(configuration: MLModelConfiguration())
            if let safeVisionModel = try? VNCoreMLModel(for: deepLab.model) {
                let visionModel = safeVisionModel
                _ = VNCoreMLRequest(model: visionModel, completionHandler: { req, err in
                    print(req.results ?? "No results")
                })
            }
            result("Deeplab loaded")
        }
        else if call.method == "createCamera" {
            let myCamera = MyCamera()
            myCamera.setupCamera(sessionPreset: .hd1280x720) { success in
                myCamera.start()
            }
            let cameraId = self.textureRegistry.register(myCamera)
            result(cameraId)
        }
        else {
            result("Custom: Not implemented")
        }
    }
}
