//
//  SearchViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {
  #warning("Move all this state to a view model and bind with Rx")
  #warning("Transition to better dependancy injection at init to avoid implicit unwraps")
  private var locationService: LocationService!
  private var debounceTimer: Timer?

  private lazy var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()
  private var startDate: Date = Date() {
    didSet {
      startDateButton.setTitle(formatter.string(from: startDate), for: .normal)
      endDatePicker.minimumDate = startDate.addingTimeInterval(24*60*60)
      endDate = max(startDate.addingTimeInterval(24*60*60), endDate)
    }
  }
  private var endDate: Date = Date() {
    didSet {
      endDateButton.setTitle(formatter.string(from: endDate), for: .normal)
    }
  }
  private var location: CLPlacemark?
  
  @IBOutlet weak var addressTextField: UITextField!
  @IBOutlet weak var startDateButton: UIButton!
  @IBOutlet weak var startDatePicker: UIDatePicker!
  @IBOutlet weak var endDateButton: UIButton!
  @IBOutlet weak var endDatePicker: UIDatePicker!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  @IBAction func useCurrentLocationTapped(_ sender: Any) {
    spinner.startAnimating()
    addressTextField.resignFirstResponder()
    locationService.requestCurrentLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationService = LocationService(delegate: self)
    setupUI()
  }
  
  @IBAction func startDateButtonTapped(_ sender: Any) {
    if(!endDatePicker.isHidden) {
      animate(picker: endDatePicker, hide: true)
    }
    animate(picker: startDatePicker, hide: !startDatePicker.isHidden)
    addressTextField.resignFirstResponder()
  }
  
  @IBAction func endDateButtonTapped(_ sender: Any) {
    if(!startDatePicker.isHidden) {
      animate(picker: startDatePicker, hide: true)
    }
    animate(picker: endDatePicker, hide: !endDatePicker.isHidden)
    addressTextField.resignFirstResponder()
  }
  
  @IBAction func startDateChanged(_ sender: UIDatePicker) {
    startDate = sender.date
  }
  @IBAction func endDateChanged(_ sender: UIDatePicker) {
    endDate = sender.date
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    return location != nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let resultsVC = segue.destination as? CarSearchResultsViewController,
      let location = location?.location else { return }
    resultsVC.viewModel = CarSearchResultsViewModel(startDate: startDate, endDate: endDate, location: location, NetworkService(keyService: KeyService()), locationService)
  }

  private func animate(picker: UIDatePicker, hide: Bool) {
    let changeAlpha = {
      picker.alpha = hide ? 0 : 1
    }
    let changeHidden = {
      picker.isHidden = hide
    }
    let firstAnimation = hide ? changeAlpha : changeHidden
    let secondAnimation = hide ? changeHidden : changeAlpha
    UIView.animate(withDuration: 0.1, animations: firstAnimation) { complete in
      UIView.animate(withDuration: 0.25, animations: secondAnimation)
    }
  }
  
  private func setupUI() {
    title = "Rentals Near You"
    startDatePicker.isHidden = true
    startDatePicker.minimumDate = Date()
    startDatePicker.maximumDate = Date().addingTimeInterval(60*60*24*359)
    endDatePicker.maximumDate = Date().addingTimeInterval(60*60*24*360)
    startDate = Date()
    endDatePicker.isHidden = true
    addressTextField.delegate = self
  }
}

extension SearchViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let oldText = textField.text {
      let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
      debounceTimer?.invalidate()
      debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.25 , repeats: false) { timer in
        self.locationService.location(forAddress: newText) { (place, error) in
          if let error = error {
            print(error.localizedDescription)
            #warning("Deal with error")
          } else if let place = place {
            self.location = place
          }
        }
      }
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if shouldPerformSegue(withIdentifier: "showSearchResults", sender: nil) {
      performSegue(withIdentifier: "showSearchResults", sender: nil)
      textField.resignFirstResponder()
    }
    return true
  }
}

extension SearchViewController: LocationServiceDelegate {
  func locationUpdated(_ location: CLPlacemark) {
    self.location = location
    addressTextField.text = location.address
    spinner.stopAnimating()
  }
  
  func locationUpdateFailed() {
    self.location = nil
    spinner.stopAnimating()
  }  
}
