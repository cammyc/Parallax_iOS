//
//  ViewController.swift
//  Parallax
//
//  Created by Cameron Connor on 11/25/18.
//  Copyright © 2018 Parallax. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import Firebase

protocol BoxServiceDelegate: class {
    func boxService(_ service: BoxService, didDetect images: [UIImage])
}

final class BoxService {
    private var layers: [CALayer] = []
    private var layers2: [CALayer] = []
    private let vision = Vision.vision()
    private var textRecognizer:VisionTextRecognizer? = nil
    
    weak var delegate: BoxServiceDelegate?
    
    init(){
        textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    func handle(cameraLayer: AVCaptureVideoPreviewLayer, image: UIImage, results: [VNTextObservation], on view: UIView) {
        reset()
        
        var images: [UIImage] = []
        let results = results.filter({ $0.confidence > 0.5 })
        
        let vision_image = VisionImage(image: image)
        textRecognizer!.process(vision_image) { result, error in
            guard error == nil, let result = result else {
                // ...
                return
            }
            
            let resultText = result.text
            for block in result.blocks {
                //            let blockText = block.text
                //            let blockConfidence = block.confidence
                //            let blockLanguages = block.recognizedLanguages
                //            let blockCornerPoints = block.cornerPoints
                let blockFrame = block.frame
                
                self.layers = results.map({ result in
                    let layer = CALayer()
                    view.layer.addSublayer(layer)
                    layer.borderWidth = 2
                    layer.borderColor = UIColor.green.cgColor
                    
                    
                    
                    if let croppedImage = self.crop(image: image, rect: blockFrame) {
                        images.append(croppedImage)
                    }
                    
                    
                    do {
                        let rect = cameraLayer.layerRectConverted(fromMetadataOutputRect: result.boundingBox)
                        layer.frame = rect
                    }
                    
                    self.layers2.append(layer)
                    return layer
                })
                
                // Recognized text
            }
            self.delegate?.boxService(self, didDetect: images)
        }
    }
    
    private func crop(image: UIImage, rect: CGRect) -> UIImage? {
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
    
    private func reset() {
        layers.forEach {
            $0.removeFromSuperlayer()
        }
        
        layers.removeAll()
        layers2.forEach {
            $0.removeFromSuperlayer()
        }
        
        layers2.removeAll()
    }
}
