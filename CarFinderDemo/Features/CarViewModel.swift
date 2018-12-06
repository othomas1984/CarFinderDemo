//
//  CarViewModel.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 12/5/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import Foundation

class CarViewModel {
  var car: CarInfo
  
  init(car: CarInfo) {
    self.car = car
  }
  static var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()
  
  var airConditioning: String {
    get {
      guard let airConditioning = car.airConditioning else {
        return "Unknown Air Conditioning"
      }
      return airConditioning ? "Has AC" : "No AC"
    }
  }
  
  var cost: String {
    guard let amountDouble = Double.init(car.estimatedTotal?.amount ?? "0") else { return "Error" }
    return CarViewModel.formatter.string(from: NSNumber.init(value: amountDouble))!
  }
}
