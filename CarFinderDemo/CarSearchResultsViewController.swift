//
//  CarSearchResultsViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit

class CarSearchResultsViewController: UIViewController {
  var cars: [CarInfo] = []
  
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    guard var urlComponents = URLComponents(string: "https://api.sandbox.amadeus.com/v1.2/cars/search-circle") else {
      #warning("Handle error")
      return
    }
    urlComponents.queryItems = [
      URLQueryItem(name: "apikey", value: "o7cZmYQRVWpoWfEgB7xGUgVj3F0DQRNw"),
      URLQueryItem(name: "latitude", value: "34.0522"),
      URLQueryItem(name: "longitude", value: "-118.2437"),
      URLQueryItem(name: "radius", value: "40"),
      URLQueryItem(name: "pick_up", value: "2018-10-25"),
      URLQueryItem(name: "drop_off", value: "2018-10-30"),
    ]
    guard let url = urlComponents.url else {
      #warning("Handle error")
      return
    }
    let request = URLRequest(url: url)
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: request) { (data, _, error) in
      guard let data = data, error == nil else {
        #warning("Handle error")
        return
      }
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      guard let result = try? decoder.decode(CarSearchResults.self, from: data) else {
        #warning("Handle error")
        return
      }
      self.cars = result.cars
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
