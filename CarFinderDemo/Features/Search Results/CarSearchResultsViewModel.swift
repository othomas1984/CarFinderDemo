//
//  CarSearchResultsViewModel.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 12/5/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import Foundation
import CoreLocation

enum CarSort {
  case company, price, distance
}

class CarSearchResultsViewModel {
  private var privateCars: [CarInfo] = []
  private var sortedCars: [CarInfo]?
  private var networkService: NetworkService
  private var locationService: LocationService
  private var startDate: Date
  private var endDate: Date
  private var location: CLLocation
  
  init(startDate: Date, endDate: Date, location: CLLocation, _ networkService: NetworkService, _ locationService: LocationService) {
    self.networkService = networkService
    self.locationService = locationService
    self.startDate = startDate
    self.endDate = endDate
    self.location = location
  }
  
  var title: String {
    return "\(cars.count) Results"
  }
  
  var sortBy: CarSort = .company {
    didSet {
      sortedCars = nil
    }
  }
  var sortAscending: Bool = true {
    didSet {
      sortedCars = nil
    }
  }
  
  var cars: [CarInfo] {
    if let sortedCars = sortedCars {
      return sortedCars
    }
    sortCars()
    return sortedCars ?? []
  }
  
  func refreshCars(completion: @escaping (Error?) -> Void) {
    networkService.getCarResults(startDate: startDate, endDate: endDate, lat: location.coordinate.latitude, long: location.coordinate.longitude) { (results, error) in
      if let error = error {
        completion(error)
        return
      }
      self.privateCars = results?.cars ?? []
      self.sortedCars = nil
      completion(nil)
    }
  }
  
  func milesFrom(pointOne: CLLocation) -> Double {
    return locationService.milesBetween(pointOne: pointOne, pointTwo: location)
  }
  
  private func sortCars() {
    sortedCars = privateCars
    .sorted {
      let companyEqual = $0.providerName == $1.providerName
      let priceEqual = Double($0.estimatedTotal?.amount ?? "0") ?? 0 == Double($1.estimatedTotal?.amount ?? "0") ?? 0
      let priceAscending = Double($0.estimatedTotal?.amount ?? "0") ?? 0 < Double($1.estimatedTotal?.amount ?? "0") ?? 0
      let companyAscending = $0.providerName < $1.providerName
      let distance1 = locationService.milesBetween(pointOne: CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude), pointTwo: location)
      let distance2 = locationService.milesBetween(pointOne: CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude), pointTwo: location)
      let distanceAscending = distance1 < distance2
      let distanceEqual = distance1 == distance2
      switch sortBy {
      case .company:
        return !companyEqual ? (sortAscending ? companyAscending : !companyAscending) :
          !distanceEqual ? distanceAscending : priceAscending
      case .price:
        return !priceEqual ? (sortAscending ? priceAscending : !priceAscending) :
          !distanceEqual ? distanceAscending : companyAscending
      case .distance:
        return !distanceEqual ? (sortAscending ? distanceAscending : !distanceAscending) :
          !companyEqual ? companyAscending : priceAscending
      }
    }
  }
}
