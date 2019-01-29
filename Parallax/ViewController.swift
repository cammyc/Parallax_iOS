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
    private var hasfoundName = false;
    
    //private let musicService = MusicService()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label2.text = "Continue With Trade"
        label2.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        label2.center.x = label.center.x
        label2.isHidden = true
//        label.text = "Searching for Username..."
        label.text = "Checking for completion"
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
        ocrService.handle(image: image)

    }
}

extension ViewController: BoxServiceDelegate {
    func boxService(_ service: BoxService, didDetect images: [UIImage]) {
        guard let biggestImage = images.sorted(by: {
            $0.size.width > $1.size.width && $0.size.height > $1.size.height
        }).first else {
            return
        }
        
        //ocrService.handle(image: biggestImage)
    }
}

extension ViewController: OCRServiceDelegate {
    func ocrService(_ service: OCRService, didDetect text: String) {
        if(!hasfoundName){//should be true, false for testing
            if(text.lowercased().trimmingCharacters(in: ["."]).levenshtein("processing trade") <= 2){
                label.text = "Trade completed!"
                label2.text = "Sending Ethereum..."

                label2.isHidden = false
                
                UIView.animate(withDuration: 1.0) {
                    
                    self.label2.center.x = self.label2.center.x - 40
                }
            }else if(text.lowercased().trimmingCharacters(in: ["."]).levenshtein("trade canceled") <= 2){
                label.text = "Trade canceled!"
                label2.text = "No $ transfered"
                
                label2.isHidden = false
                
                UIView.animate(withDuration: 1.0) {
                    
                    self.label2.center.x = self.label2.center.x - 40
                }
            }
        }else{
            if(text.lowercased() == "martinspt22"){
                label.text = "UN: " + text.uppercased()
                label2.isHidden = false
                
                UIView.animate(withDuration: 1.0) {
                    
                    self.label2.center.x = self.label2.center.x - 40
                }
            }
        }
        
        print(text.lowercased().trimmingCharacters(in: ["."]));
        print(text.lowercased().trimmingCharacters(in: ["."]).levenshtein("trade has been canceled"))
    }
}

extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

extension String {
    public func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count
        
        guard sCount != 0 else {
            return oCount
        }
        
        guard oCount != 0 else {
            return sCount
        }
        
        let line : [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat : [[Int]] = Array(repeating: line, count: sCount + 1)
        
        for i in 0...sCount {
            mat[i][0] = i
        }
        
        for j in 0...oCount {
            mat[0][j] = j
        }
        
        for j in 1...oCount {
            for i in 1...sCount {
                if self[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                }
                else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }
        
        return mat[sCount][oCount]
    }
}

