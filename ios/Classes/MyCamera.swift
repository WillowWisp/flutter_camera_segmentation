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
    var pixelBuffer: CVPixelBuffer?
    var onFrameAvailable: (() -> Void)?
    
    var request: VNCoreMLRequest?
    
    func setupCamera(sessionPreset: AVCaptureSession.Preset, position: AVCaptureDevice.Position? = .back, completion: @escaping (_ success: Bool) -> Void) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        _ = DispatchQueue(label: "com.tucan9389.camera-queue")
        
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
        
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // We want the buffers to be in portrait orientation otherwise they are
        // rotated by 90 degrees. Need to set this _after_ addOutput()!
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        
        captureSession.commitConfiguration()
        
        completion(true)
    }
    
    func setupMlModel() {
        let deepLab = try! DeepLabV3(configuration: MLModelConfiguration())
        if let visionModel = try? VNCoreMLModel(for: deepLab.model) {
            request = VNCoreMLRequest(model: visionModel, completionHandler: { req, err in
                print(req.results ?? "No results")
            })
        }
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
}

// - MARK: VideoOutputBufferDelegate

extension MyCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        if let onFrameAvailable = onFrameAvailable {
            onFrameAvailable()
        }
        
//        if let pixelBuffer = pixelBuffer, let request = request {
//            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//            try? handler.perform([request])
//        }
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
