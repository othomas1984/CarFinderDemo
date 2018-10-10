//
//  SearchViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 10/9/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  lazy var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
  }()
  var startDate: Date = Date() {
    didSet {
      startDateButton.setTitle(formatter.string(from: startDate), for: .normal)
      endDatePicker.minimumDate = startDate.addingTimeInterval(24*60*60)
      endDate = max(startDate.addingTimeInterval(24*60*60), endDate)
    }
  }
  var endDate: Date = Date() {
    didSet {
      endDateButton.setTitle(formatter.string(from: endDate), for: .normal)
    }
  }
  
  @IBOutlet weak var startDateButton: UIButton!
  @IBOutlet weak var startDatePicker: UIDatePicker!
  @IBOutlet weak var endDateButton: UIButton!
  @IBOutlet weak var endDatePicker: UIDatePicker!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  @IBAction func startDateButtonTapped(_ sender: Any) {
    if(!endDatePicker.isHidden) {
      animate(picker: endDatePicker, hide: true)
    }
    animate(picker: startDatePicker, hide: !startDatePicker.isHidden)
  }
  
  @IBAction func endDateButtonTapped(_ sender: Any) {
    if(!startDatePicker.isHidden) {
      animate(picker: startDatePicker, hide: true)
    }
    animate(picker: endDatePicker, hide: !endDatePicker.isHidden)
  }
  
  @IBAction func startDateChanged(_ sender: UIDatePicker) {
    startDate = sender.date
  }
  @IBAction func endDateChanged(_ sender: UIDatePicker) {
    endDate = sender.date
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let resultsVC = segue.destination as? CarSearchResultsViewController else { return }
    resultsVC.startDate = startDate
    resultsVC.endDate = endDate
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
    startDatePicker.isHidden = true
    startDatePicker.minimumDate = Date()
    startDate = Date()
    endDatePicker.isHidden = true
  }
}
