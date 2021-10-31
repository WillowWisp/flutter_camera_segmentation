import Flutter
import UIKit
import Vision
import CoreML

public class SwiftFlutterCameraSegmentationPlugin: NSObject, FlutterPlugin {
    var textureRegistry: FlutterTextureRegistry
    var myCamera: MyCamera?
    var cameraTextureId: Int64?
    
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
        if call.method == "createCamera" {
            myCamera = MyCamera()
            if let myCamera = myCamera {
                cameraTextureId = textureRegistry.register(myCamera)
                guard let cameraTextureId = cameraTextureId else {
                    return
                }
                
                myCamera.setupCamera(sessionPreset: .hd1920x1080) { success in
                    myCamera.start({ [self] in
                        textureRegistry.textureFrameAvailable(cameraTextureId)
                    })
                }
                result(cameraTextureId)
            }
        }
        else if call.method == "disposeCamera" {
            if let myCamera = myCamera, let cameraTextureId = cameraTextureId {
                textureRegistry.unregisterTexture(cameraTextureId)
                myCamera.close()
            }
            result(nil)
        }
        else if call.method == "capturePhoto" {
            if let myCamera = myCamera {
                myCamera.capturePhoto(result: result)
            }
        }
        else {
            result("Custom: Not implemented")
        }
    }
}
