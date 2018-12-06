//
//  Models.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import Foundation

struct CarSearchResults: Decodable {
  var results: [CarSearchResult]
  var cars: [CarInfo] {
    return results.flatMap { company in
      company.cars.map { car in
        CarInfo(rates: car.rates, acrissCode: car.vehicleInfo.acrissCode, transmission: car.vehicleInfo.transmission, fuel: car.vehicleInfo.fuel, airConditioning: car.vehicleInfo.airConditioning, category: car.vehicleInfo.category, type: car.vehicleInfo.type, providerName: company.provider.companyName, estimatedTotal: car.estimatedTotal, image: car.image, address: company.address, location: company.location)
      }
    }
  }
}

struct CarSearchResult: Decodable {
  var provider: Provider
  var address: Address
  var branchId: String
  var cars: [Car]
  var location: Location
}

struct Provider: Decodable {
  var companyName: String
}

struct Location: Decodable {
  var latitude: Double
  var longitude: Double
}

struct Address: Decodable {
  var line1: String
  var city: String
  var country: String
}

struct Car: Decodable {
  var rates: [Rate]
  var vehicleInfo: VehicleInfo
  var estimatedTotal: Cost?
  var image: Image?  
}

struct CarInfo {
  var rates: [Rate]
  var acrissCode: String
  var transmission: String
  var fuel: String
  var airConditioning: Bool?
  var category: String
  var type: String
  var providerName: String
  var estimatedTotal: Cost?
  var image: Image?
  var address: Address
  var location: Location
}

struct VehicleInfo: Decodable {
  var acrissCode: String
  var transmission: String = "Unknown Transmission"
  var fuel: String = "Unknown Fuel Type"
  var airConditioning: Bool?
  var category: String
  var type: String = "Unknown Type"
}

struct Rate: Decodable {
  var type: String
  var price: Cost
}

extension Cost {
  static var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
  }()
  
  var currencyString: String {
    guard let amountDouble = Double(amount),
      let amount = CarViewModel.formatter.string(from: NSNumber(value: amountDouble)) else { return "Error" }
    return amount
  }
}

struct Cost: Decodable {
  var amount: String
  var currency: String
}

struct Image: Decodable {
  var width: Int
  var height: Int
  var url: URL
}
