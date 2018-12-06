//
//  CarSearchResultsViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit
import CoreLocation

class CarSearchResultsViewController: UIViewController {
  enum CarSort {
    case company, price, distance
  }
  
  var keyService: KeyService!
  var locationService: LocationService!
  var networkService: NetworkService!
  var startDate: Date!
  var endDate: Date!
  var location: CLLocation!
  var sortBy: CarSort = .company {
    didSet {
      sortCars(by: sortBy, ascending: sortAscending)
    }
  }
  var sortAscending: Bool = true {
    didSet {
      sortCars(by: sortBy, ascending: sortAscending)
    }
  }
  
  var cars: [CarInfo] = []
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var sortPickerView: UIPickerView!
  @IBOutlet weak var sortOverlayView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Searching..."
    sortPickerView.dataSource = self
    sortPickerView.delegate = self
    keyService = KeyService()
    locationService = LocationService()
    networkService = NetworkService(keyService: keyService)
  
    networkService.getCarResults(startDate: startDate, endDate: endDate, lat: location.coordinate.latitude, long: location.coordinate.longitude) { (results, error) in
      if let error = error {
        self.title = "Error: 0 Results"
        #warning("Do something better with errors here")
        self.displayGenericAlert(title: "Network Error", message: error.localizedDescription)
        return
      }
      guard let results = results else {
        #warning("Use a Result type here so that results are always populated if error is not")
        self.displayGenericAlert(title: "Unknown Error", message: "We should never get here if error above is nil")
        return
      }
      self.cars = results.cars
      self.sortCars(by: self.sortBy, ascending: self.sortAscending)
      self.title = "\(self.cars.count) Results"
      self.tableView.reloadData()
    }
  }
  
  @IBAction func sortButtonTapped(_ sender: Any) {
    sortOverlayView.isHidden = !sortOverlayView.isHidden
  }
  
  func sortCars(by sortType: CarSort, ascending: Bool) {
    cars = cars
      .sorted {
        let companyEqual = $0.providerName == $1.providerName
        let priceEqual = Double($0.estimatedTotal?.amount ?? "0") ?? 0 == Double($1.estimatedTotal?.amount ?? "0") ?? 0
        let priceAscending = Double($0.estimatedTotal?.amount ?? "0") ?? 0 < Double($1.estimatedTotal?.amount ?? "0") ?? 0
        let companyAscending = $0.providerName < $1.providerName
        let distance1 = locationService.milesBetween(pointOne: CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude), pointTwo: location)
        let distance2 = locationService.milesBetween(pointOne: CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude), pointTwo: location)
        let distanceAscending = distance1 < distance2
        let distanceEqual = distance1 == distance2
        switch sortType {
        case .company:
          return !companyEqual ? (ascending ? companyAscending : !companyAscending) :
            !distanceEqual ? distanceAscending : priceAscending
        case .price:
          return !priceEqual ? (ascending ? priceAscending : !priceAscending) :
            !distanceEqual ? distanceAscending : companyAscending
        case .distance:
          return !distanceEqual ? (ascending ? distanceAscending : !distanceAscending) :
            !companyEqual ? companyAscending : priceAscending
        }
    }
  }
}

extension CarSearchResultsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cars.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
    let car = cars[indexPath.row]
    let miles = locationService.milesBetween(pointOne: CLLocation(latitude: car.location.latitude, longitude: car.location.longitude), pointTwo: location)
    let milesString = " (\(round(miles * 100) / 100)m)"
    cell.textLabel?.text = car.providerName + ": " + car.category + milesString
    if let estimate = car.estimatedTotal {
      cell.detailTextLabel?.text = estimate.amount + " " + estimate.currency
    } else {
      cell.detailTextLabel?.text = "Tap for Price"
    }
    return cell
  }
}

extension CarSearchResultsViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return component == 0 ? 3 : 2
  }
}

extension CarSearchResultsViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return [["Company", "Distance", "Price"], ["Ascending", "Descending"]][component][row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if component == 0 {
      self.sortBy = [CarSort.company, CarSort.distance, CarSort.price][row]
    } else {
      self.sortAscending = row == 0
    }
    tableView.reloadData()
  }
}
