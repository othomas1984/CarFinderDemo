//
//  Models.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

struct CarSearchResults: Codable {
  var results: [CarSearchResult]
  var cars: [CarInfo] {
    return results.flatMap { result in
      result.cars.map { apiCar in
        CarInfo(rates: apiCar.rates, acrissCode: apiCar.vehicleInfo.acrissCode, transmission: apiCar.vehicleInfo.transmission, fuel: apiCar.vehicleInfo.fuel, airConditioning: apiCar.vehicleInfo.airConditioning, category: apiCar.vehicleInfo.category, type: apiCar.vehicleInfo.type, providerName: result.provider.companyName, estimatedTotal: apiCar.estimatedTotal)
      }
    }
  }
}

struct CarSearchResult: Codable {
  var provider: Provider
  var address: Address
  var branchId: String
  var cars: [Car]
}

struct Provider: Codable {
  var companyName: String
}

struct Address: Codable {
  var line1: String
  var city: String
  var country: String
}

struct Car: Codable {
  var rates: [Rate]
  var vehicleInfo: VehicleInfo
  var estimatedTotal: Cost
}

struct CarInfo: Codable {
  var rates: [Rate]
  var acrissCode: String
  var transmission: String
  var fuel: String
  var airConditioning: Bool
  var category: String
  var type: String
  var providerName: String
  var estimatedTotal: Cost
}

struct VehicleInfo: Codable {
  var acrissCode: String
  var transmission: String
  var fuel: String
  var airConditioning: Bool
  var category: String
  var type: String
}

struct Rate: Codable {
  var type: String
  var price: Cost
}

struct Cost: Codable {
  var amount: String
  var currency: String
}
