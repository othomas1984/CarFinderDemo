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
  var viewModel: CarSearchResultsViewModel!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var sortPickerView: UIPickerView!
  @IBOutlet weak var sortOverlayView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Searching..."
    sortPickerView.dataSource = self
    sortPickerView.delegate = self
    viewModel.refreshCars { (error) in
      if let error = error {
        self.displayGenericAlert(title: "Network Error", message: error.localizedDescription)
      }
      self.updateUI()
    }
  }
  
  func updateUI() {
    title = viewModel.title
    tableView.reloadData()
  }
  
  @IBAction func sortButtonTapped(_ sender: Any) {
    sortOverlayView.isHidden = !sortOverlayView.isHidden
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destination = segue.destination as? CarViewController,
      let indexPath = tableView.indexPathForSelectedRow else { return }
    let model = CarViewModel(car: viewModel.cars[indexPath.row])
    destination.viewModel = model
    tableView.cellForRow(at: indexPath)?.isSelected = false
  }
}

extension CarSearchResultsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.cars.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "carCell", for: indexPath)
    let car = viewModel.cars[indexPath.row]
    let miles = viewModel.milesFrom(pointOne: CLLocation(latitude: car.location.latitude, longitude: car.location.longitude))
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
      viewModel.sortBy = [CarSort.company, CarSort.distance, CarSort.price][row]
    } else {
      viewModel.sortAscending = row == 0
    }
    updateUI()
  }
}
