//
//  ViewController+Extensions.swift
//  BigBigNumbers
//
//  Created by Khoa Pham on 26.05.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit

extension UIViewController {
  func add(childController: UIViewController) {
    childController.willMove(toParent: self)
    view.addSubview(childController.view)
    childController.didMove(toParent: self)
  }
}
