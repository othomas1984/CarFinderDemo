//
//  LocationService.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 11/18/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import CoreLocation

protocol LocationServiceDelegate {
  func locationUpdated(_ location: CLPlacemark)
  func locationUpdateFailed()
}

class LocationService: NSObject {
  enum LocationServiceError: Error {
    case apiError(reason: String)
    case noPlacemarkFound
  }
  let geoCoder = CLGeocoder()
  lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.delegate = self
    return manager
  }()
  
  let delegate: LocationServiceDelegate?
  
  init(delegate: LocationServiceDelegate? = nil) {
    self.delegate = delegate
  }
  
  func milesBetween(pointOne: CLLocation, pointTwo: CLLocation) -> Double {
    return pointOne.distance(from: pointTwo) / 1609.34
  }
  
  func requestCurrentLocation() {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.requestLocation()
    case .denied, .restricted:
      delegate?.locationUpdateFailed()
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
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

extension LocationService: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      delegate?.locationUpdateFailed()
      return
    }
    geoCoder.reverseGeocodeLocation(location) { (places, error) in
      guard error == nil, let place = places?.first else {
        self.delegate?.locationUpdateFailed()
        return
      }
      self.delegate?.locationUpdated(place)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    delegate?.locationUpdateFailed()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.requestLocation()
    case .notDetermined:
      break
    default:
      delegate?.locationUpdateFailed()
    }
  }
}

extension CLPlacemark {
  var address: String? {
    var result = ""
    if let streetNumber = subThoroughfare {
      result += "\(streetNumber)"
    }
    if let street = thoroughfare {
      result += " \(street)"
    }
    if let city = locality {
      result += ", \(city)"
    }
    if let state = administrativeArea {
      result += ", \(state)"
    }
    if let postalCode = postalCode {
      result += " \(postalCode)"
    }
    return result
  }
}
