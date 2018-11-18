//
//  CarSearchResultsViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit

class CarSearchResultsViewController: UIViewController {
  var keyService: KeyService!
  var startDate: Date!
  var endDate: Date!
  var lat: String!
  var long: String!
  
  var cars: [CarInfo] = []
  var sortedCars: [CarInfo] {
    get {
      return cars
        .sorted {
          let providerEqual = $0.providerName == $1.providerName
          let categoryEqual = $0.category == $1.category
          let amountAscending = Double($0.estimatedTotal?.amount ?? "0") ?? 0 < Double($1.estimatedTotal?.amount ?? "0") ?? 0
          let providerAscending = $0.providerName < $1.providerName
          let categoryAscending = $0.category < $1.category
          return !providerEqual ? providerAscending :
            !categoryEqual ? categoryAscending : amountAscending
      }
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Searching..."
    keyService = KeyService()
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
      URLQueryItem(name: "latitude", value: lat),
      URLQueryItem(name: "longitude", value: long),
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
      DispatchQueue.main.async {
        self.title = "\(self.cars.count) Results"
        self.tableView.reloadData()
      }
    }
    task.resume()
  }
}

extension CarSearchResultsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortedCars.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
    let car = sortedCars[indexPath.row]
    cell.textLabel?.text = car.providerName + ": " + car.category
    if let estimate = car.estimatedTotal {
      cell.detailTextLabel?.text = estimate.amount + " " + estimate.currency
    } else {
      cell.detailTextLabel?.text = "Tap for Price"
    }
    return cell
  }
}
