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
    return results.flatMap { result in
      result.cars.map { apiCar in
        CarInfo(rates: apiCar.rates, acrissCode: apiCar.vehicleInfo.acrissCode, transmission: apiCar.vehicleInfo.transmission, fuel: apiCar.vehicleInfo.fuel, airConditioning: apiCar.vehicleInfo.airConditioning, category: apiCar.vehicleInfo.category, type: apiCar.vehicleInfo.type, providerName: result.provider.companyName, estimatedTotal: apiCar.estimatedTotal, image: apiCar.image, address: result.address, location: result.location)
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

struct Cost: Decodable {
  var amount: String
  var currency: String
}

struct Image: Decodable {
  var width: Int
  var height: Int
  var url: URL
}
