//
//  CameraService.swift
//  A3-EasyCash
//
//  Created by Umar Abdul Azis on 21/07/25.
//

import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var currentInput: AVCaptureDeviceInput?
    private var currentPosition: CameraPreference = .front
    
    @Published var isCameraReady: Bool = false
    @Published var isVerifying: Bool = true
    
    func configure(position: CameraPreference = .front) {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        if let input = currentInput {
            session.removeInput(input)
        }
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                             for: .video,
                                             position: position == .front ? .front : .back)
        
        guard let camera = device,
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input),
              session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(input)
        session.addOutput(output)
        currentInput = input
        currentPosition = position
        
        session.commitConfiguration()
        
        DispatchQueue.main.async {
            self.isCameraReady = true
        }
        
        session.startRunning()
    }
    
    //    func switchCamera() {
    //        isCameraReady = false
    //        let newPosition: CameraPreference = currentPosition == .front ? .back : .front
    //        configure(position: newPosition)
    //    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        isVerifying = true
        output.capturePhoto(with: settings, delegate: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isVerifying = false
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation() {
            print("Photo captured with size: \(data.count) bytes")
            //can add convert to UIImage and store later
        }
    }
}

enum CameraPreference {
    case front
    case back
}
