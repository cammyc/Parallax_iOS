//
//  CameraController.swift
//  Parallax
//
//  Created by Cameron Connor on 11/25/18.
//  Copyright © 2018 Parallax. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraControllerDelegate: class {
    func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer)
}

var timer = Timer()

final class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private(set) lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else {
                return session
        }
        
        session.addInput(input)
        return session
    }()
    
    weak var delegate: CameraControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraLayer)
        
        // register to receive buffers from the camera
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        
        // begin the session
        self.captureSession.startRunning()
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.analyze), userInfo: nil, repeats: true)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // make sure the layer is the correct size
        self.cameraLayer.frame = view.bounds
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection) {
        
        sample = sampleBuffer
    }
    
    @objc func analyze(){
        if let sample = sample {
            delegate?.cameraController(self, didCapture: sample)
        }
    }
    
    // FIXME: Test
    var sample: CMSampleBuffer?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
//        if let sample = sample {
//            delegate?.cameraController(self, didCapture: sample)
//        }
    }
}
