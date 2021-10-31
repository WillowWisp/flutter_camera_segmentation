//
//  MyCamera.swift
//  flutter_camera_segmentation
//
//  Created by Nguyen Thang on 27/09/2021.
//

import Foundation
import AVFoundation
import Vision
import CoreML

class MyCamera: NSObject {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let photoOutput = AVCapturePhotoOutput()
    var pixelBuffer: CVPixelBuffer?
    var onFrameAvailable: (() -> Void)?
    
    var flutterResult: FlutterResult?
    
    // private lazy var torchModule: TorchModule = {
    //     let filePath = Bundle.main.path(forResource:
    //                                         "deeplabv3_scripted", ofType: "pt")
    //     if let filePath = filePath, let module = TorchModule(fileAtPath: filePath) {
    //         return module
    //     } else {
    //         fatalError("Can't find the model file!")
    //     }
    // }()
    
    func setupCamera(sessionPreset: AVCaptureSession.Preset, position: AVCaptureDevice.Position? = .back, completion: @escaping (_ success: Bool) -> Void) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        let device: AVCaptureDevice?
        if let position = position {
            device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first
        } else {
            device = AVCaptureDevice.default(for: AVMediaType.video)
        }
        
        guard let captureDevice = device else {
            print("Error: no video devices available")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: could not create AVCaptureDeviceInput")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let settings: [String : Any] = [
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
        ]
        
        // * Add video output (for image stream listener)
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        let queue = DispatchQueue(label: "com.willow614.camera-queue")
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // We want the buffers to be in portrait orientation otherwise they are
        // rotated by 90 degrees. Need to set this _after_ addOutput()!
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        
        // * Add photo output (for taking picture)
        
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.commitConfiguration()
        
        completion(true)
    }
    
    func start(_ onFrameAvailable: @escaping () -> Void) {
        if !captureSession.isRunning {
            captureSession.startRunning()
            self.onFrameAvailable = onFrameAvailable
        }
    }
    
    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func capturePhoto(result: @escaping FlutterResult) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = false
        
        if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
        }
        
        flutterResult = result
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func close() {
        captureSession.stopRunning()
        for captureInput in captureSession.inputs {
            captureSession.removeInput(captureInput)
        }
        for captureOutput in captureSession.outputs {
            captureSession.removeOutput(captureOutput)
        }
    }
}

extension MyCamera: FlutterTexture {
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if let pixelBuffer = pixelBuffer {
            return Unmanaged<CVPixelBuffer>.passRetained(pixelBuffer)
        }
        
        return nil
    }
}

// - MARK: VideoOutputBufferDelegate

extension MyCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        if let onFrameAvailable = onFrameAvailable {
            onFrameAvailable()
        }
        
        // Test Segmentation
        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
            if let _ = CVPixelBufferGetBaseAddress(pixelBuffer) {
                //                self.torchModule.segment(image: x, withWidth: 640, withHeight: 640)
            }
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        }
    }
}

extension MyCamera: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
//                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
//                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
//                     resolvedSettings: AVCaptureResolvedPhotoSettings,
//                     bracketSettings: AVCaptureBracketedStillImageSettings?,
//                     error: Error?) {
//
//        if let error = error {
//            print("Error capturing photo: \(error)")
//        } else {
//            if let sampleBuffer = photoSampleBuffer,
//               let previewBuffer = previewPhotoSampleBuffer,
//               let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
//                forJPEGSampleBuffer: sampleBuffer,
//                previewPhotoSampleBuffer: previewBuffer
//               ) {
//
//                print("Old photoOutput")
//                print(dataImage.count)
//
//            }
//        }
//    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let flutterResult = flutterResult else {
            return
        }
        
        guard let data = photo.fileDataRepresentation() else {
            flutterResult(nil)
            return
        }
        
        let a = [UInt8](data)
        print(a.count)
        
        flutterResult(a)
    }
}
