//
//  ViewController.swift
//  Parallax
//
//  Created by Cameron Connor on 11/25/18.
//  Copyright © 2018 Parallax. All rights reserved.
//

import Vision
import AVFoundation
import UIKit

protocol VisionServiceDelegate: class {
  func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation])
}

final class VisionService {

  weak var delegate: VisionServiceDelegate?

  func handle(buffer: CMSampleBuffer) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
      return
    }

    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    guard let image = ciImage.toUIImage() else {
      return
    }

    makeRequest(image: image)
  }

  private func inferOrientation(image: UIImage) -> CGImagePropertyOrientation {
    switch image.imageOrientation {
    case .up:
      return CGImagePropertyOrientation.up
    case .upMirrored:
      return CGImagePropertyOrientation.upMirrored
    case .down:
      return CGImagePropertyOrientation.down
    case .downMirrored:
      return CGImagePropertyOrientation.downMirrored
    case .left:
      return CGImagePropertyOrientation.left
    case .leftMirrored:
      return CGImagePropertyOrientation.leftMirrored
    case .right:
      return CGImagePropertyOrientation.right
    case .rightMirrored:
      return CGImagePropertyOrientation.rightMirrored
    }
  }

  private func makeRequest(image: UIImage) {
    guard let cgImage = image.cgImage else {
      assertionFailure()
      return
    }

    let handler = VNImageRequestHandler(
      cgImage: cgImage,
      orientation: inferOrientation(image: image),
      options: [VNImageOption: Any]()
    )

    let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] request, error in
      DispatchQueue.main.async {
        self?.handle(image: image, request: request, error: error)
      }
    })

    request.reportCharacterBoxes = true

    do {
      try handler.perform([request])
    } catch {
      print(error as Any)
    }
  }

  private func handle(image: UIImage, request: VNRequest, error: Error?) {
    guard
      let results = request.results as? [VNTextObservation]
    else {
      return
    }

    delegate?.visionService(self, didDetect: image, results: results)
  }
}
