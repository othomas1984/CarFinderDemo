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
        CarInfo(rates: apiCar.rates, acrissCode: apiCar.vehicleInfo.acrissCode, transmission: apiCar.vehicleInfo.transmission, fuel: apiCar.vehicleInfo.fuel, airConditioning: apiCar.vehicleInfo.airConditioning, category: apiCar.vehicleInfo.category, type: apiCar.vehicleInfo.type, providerName: result.provider.companyName, estimatedTotal: apiCar.estimatedTotal, image: apiCar.image, address: result.address)
      }
    }
  }
}

struct CarSearchResult: Decodable {
  var provider: Provider
  var address: Address
  var branchId: String
  var cars: [Car]
}

struct Provider: Decodable {
  var companyName: String
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
  
  enum CodingKeys: String, CodingKey {
    case rates, vehicleInfo, estimatedTotal, image
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    rates = try values.decode([Rate].self, forKey: .rates)
    vehicleInfo = try values.decode(VehicleInfo.self, forKey: .vehicleInfo)
    estimatedTotal = try values.decodeIfPresent(Cost.self, forKey: .estimatedTotal)
    image = try values.decodeIfPresent(Image.self, forKey: .image)
  }
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
}

struct VehicleInfo: Decodable {
  var acrissCode: String
  var transmission: String
  var fuel: String
  var airConditioning: Bool?
  var category: String
  var type: String
  
  enum CodingKeys: String, CodingKey {
    case acrissCode, transmission, fuel, airConditioning, category, type
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    acrissCode = try values.decode(String.self, forKey: .acrissCode)
    transmission = try values.decodeIfPresent(String.self, forKey: .transmission) ?? "Unknown Transmission"
    fuel = try values.decodeIfPresent(String.self, forKey: .fuel) ?? "Unknown Fuel Type"
    airConditioning = try values.decodeIfPresent(Bool.self, forKey: .airConditioning)
    category = try values.decode(String.self, forKey: .category)
    type = try values.decodeIfPresent(String.self, forKey: .type) ?? "Unknown Type"
  }
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
