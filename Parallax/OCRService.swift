//
//  ViewController.swift
//  Parallax
//
//  Created by Cameron Connor on 11/25/18.
//  Copyright © 2018 Parallax. All rights reserved.
//

import SwiftOCR
import TesseractOCR
import Firebase

protocol OCRServiceDelegate: class {
  func ocrService(_ service: OCRService, didDetect text: String)
}

final class OCRService {
  private let instance = SwiftOCR()
  private let tesseract = G8Tesseract(language: "eng")!
    private let vision = Vision.vision()
    private var textRecognizer:VisionTextRecognizer? = nil

  weak var delegate: OCRServiceDelegate?

  init() {
    tesseract.engineMode = .tesseractCubeCombined
    tesseract.pageSegmentationMode = .singleLine
    textRecognizer = vision.onDeviceTextRecognizer()

  }

  func handle(image: UIImage) {
    handleWithTesseract(image: image)
  }

  private func handleWithSwiftOCR(image: UIImage) {
    instance.recognize(image, { string in
      DispatchQueue.main.async {
        self.delegate?.ocrService(self, didDetect: string)
      }
    })
  }

  private func handleWithTesseract(image: UIImage) {
    let image = VisionImage(image: image)
    textRecognizer!.process(image) { result, error in
        guard error == nil, let result = result else {
            // ...
            return
        }
        
        let resultText = result.text
        for block in result.blocks {
            let blockText = block.text
            let blockConfidence = block.confidence
            let blockLanguages = block.recognizedLanguages
            let blockCornerPoints = block.cornerPoints
            let blockFrame = block.frame
            for line in block.lines {
                let lineText = line.text
                let lineConfidence = line.confidence
                let lineLanguages = line.recognizedLanguages
                let lineCornerPoints = line.cornerPoints
                let lineFrame = line.frame
                for element in line.elements {
                    let elementText = element.text
                    //print(elementText)
                    self.delegate?.ocrService(self, didDetect: elementText)
                    let elementConfidence = element.confidence
                    let elementLanguages = element.recognizedLanguages
                    let elementCornerPoints = element.cornerPoints
                    let elementFrame = element.frame
                }
            }
        }
        
        // Recognized text
    }
//   tesseract.image = image.g8_blackAndWhite()
//    tesseract.recognize()
//    let text = tesseract.recognizedText ?? ""
   
  }
}
