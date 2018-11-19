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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Searching..."
    sortPickerView.dataSource = self
    sortPickerView.delegate = self
    keyService = KeyService()
    locationService = LocationService()
    guard var urlComponents = URLComponents(string: "https://api.sandbox.amadeus.com/v1.2/cars/search-circle") else {
      print("URL Error")
      #warning("Handle error")
      return
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let start = formatter.string(from: startDate)
    let end = formatter.string(from: endDate)
    let apiKey: String
    do {
      apiKey = try keyService.key(forName: "amadeusAPIKey")
    } catch {
      apiKey = "Unknown Key"
      print(error.localizedDescription)
    }
    urlComponents.queryItems = [
      URLQueryItem(name: "apikey", value: apiKey),
      URLQueryItem(name: "latitude", value: String(describing: location.coordinate.latitude)),
      URLQueryItem(name: "longitude", value: String(describing: location.coordinate.longitude)),
      URLQueryItem(name: "radius", value: "40"),
      URLQueryItem(name: "pick_up", value: start),
      URLQueryItem(name: "drop_off", value: end),
    ]
    guard let url = urlComponents.url else {
      print("Error getting url from components")
      #warning("Handle error")
      return
    }
    let request = URLRequest(url: url)
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: request) { (data, response, error) in
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
      guard statusCode >= 200, statusCode < 300 else {
        print("Network Error: HTTP Code \(statusCode)")
        if let data = data,
          let error = try? JSONSerialization.jsonObject(with: data, options: []),
          let errorDict = error as? [String: Any],
          let message = errorDict["message"] as? String {
          print(message)
        }
        #warning("Handle error")
        DispatchQueue.main.async {
          self.title = "0 Results"
        }
        return
      }
      guard let data = data, error == nil else {
        print("Error fetching data: \(error?.localizedDescription ?? "Unknown Error")")
        #warning("Handle error")
        DispatchQueue.main.async {
          self.title = "0 Results"
        }
        return
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      guard let result = try? decoder.decode(CarSearchResults.self, from: data) else {
        print("Error decoding search results")
        #warning("Handle error")
        DispatchQueue.main.async {
          self.title = "0 Results"
        }
        return
      }
      self.cars = result.cars
      self.sortCars(by: self.sortBy, ascending: self.sortAscending)
      DispatchQueue.main.async {
        self.title = "\(self.cars.count) Results"
        self.tableView.reloadData()
      }
    }
    task.resume()
  }
  
  @IBAction func sortButtonTapped(_ sender: Any) {
    sortPickerView.isHidden = !sortPickerView.isHidden
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
