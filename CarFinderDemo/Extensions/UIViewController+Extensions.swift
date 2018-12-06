//
//  UIViewController+Extensions.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 12/5/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit

extension UIViewController {
  func displayGenericAlert(title: String?, message: String?) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Ok", style: .default))
    present(ac, animated: true)
  }
}
