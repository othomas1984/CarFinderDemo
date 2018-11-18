//
//  LocationService.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 11/18/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import CoreLocation

class LocationService {
  enum LocationServiceError: Error {
    case apiError(reason: String)
    case noPlacemarkFound
  }
  let geoCoder = CLGeocoder()
  
  func location(forAddress address: String, completion: @escaping ((CLPlacemark?, LocationServiceError?) -> Void)) {
    geoCoder.geocodeAddressString(address) { (places, error) in
      if let error = error {
        completion(nil, .apiError(reason: error.localizedDescription))
        return
      }
      guard let places = places else {
        completion(nil, .noPlacemarkFound)
        return
      }
      completion(places.first, nil)
    }
  }
}
