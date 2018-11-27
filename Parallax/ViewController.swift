//
//  ViewController.swift
//  Parallax
//
//  Created by Cameron Connor on 11/25/18.
//  Copyright © 2018 Parallax. All rights reserved.
//

import UIKit
import Anchors
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    private let cameraController = CameraController()
    private let visionService = VisionService()
    private let boxService = BoxService()
    private let ocrService = OCRService()
    //private let musicService = MusicService()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label2.text = "Continue With Trade"
        label2.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        label2.center.x = label.center.x
        label2.isHidden = true
        label.text = "Searching for Username..."
        label.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        
        cameraController.delegate = self
        add(childController: cameraController)
        activate(
            cameraController.view.anchor.edges
        )
        
        view.addSubview(label)
        view.addSubview(label2)
        
        
        visionService.delegate = self
        boxService.delegate = self
        ocrService.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

extension ViewController: CameraControllerDelegate {
    func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer) {
        visionService.handle(buffer: buffer)
    }
}

extension ViewController: VisionServiceDelegate {
    func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation]) {
        boxService.handle(
            cameraLayer: cameraController.cameraLayer,
            image: image,
            results: results,
            on: cameraController.view
        )
    }
}

extension ViewController: BoxServiceDelegate {
    func boxService(_ service: BoxService, didDetect images: [UIImage]) {
        guard let biggestImage = images.sorted(by: {
            $0.size.width > $1.size.width && $0.size.height > $1.size.height
        }).first else {
            return
        }
        
        ocrService.handle(image: biggestImage)
    }
}

extension ViewController: OCRServiceDelegate {
    func ocrService(_ service: OCRService, didDetect text: String) {
        if(text.lowercased() == "martinspt22"){
            label.text = "UN: " + text.uppercased()
            label2.isHidden = false
            
            UIView.animate(withDuration: 1.0) {

                self.label2.center.x = self.label2.center.x - 40
            }
        }
        print(text);
    }
}

