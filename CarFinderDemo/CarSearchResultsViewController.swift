//
//  CarSearchResultsViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit

class CarSearchResultsViewController: UIViewController {
  var startDate = Date()
  var endDate = Date()
  var cars: [CarInfo] = []
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    guard var urlComponents = URLComponents(string: "https://api.sandbox.amadeus.com/v1.2/cars/search-circle") else {
      print("URL Error")
      #warning("Handle error")
      return
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    let start = formatter.string(from: startDate)
    let end = formatter.string(from: endDate)
      
    urlComponents.queryItems = [
      URLQueryItem(name: "apikey", value: "o7cZmYQRVWpoWfEgB7xGUgVj3F0DQRNw"),
      URLQueryItem(name: "latitude", value: "34.0522"),
      URLQueryItem(name: "longitude", value: "-118.2437"),
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
        #warning("Handle error")
        return
      }
      guard let data = data, error == nil else {
        print("Error fetching data: \(error?.localizedDescription ?? "Unknown Error")")
        #warning("Handle error")
        return
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      guard let result = try? decoder.decode(CarSearchResults.self, from: data) else {
        print("Error decoding search results")
        #warning("Handle error")
        return
      }
      self.cars = result.cars
      print("Cars found: \(self.cars.count)")
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
    task.resume()
  }
}

extension CarSearchResultsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cars.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
    let car = cars[indexPath.row]
    cell.textLabel?.text = car.providerName + ": " + car.category
    cell.detailTextLabel?.text = car.estimatedTotal.amount + " " + car.estimatedTotal.currency
    return cell
  }
}
