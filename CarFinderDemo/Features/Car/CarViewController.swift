//
//  CarViewController.swift
//  CarFinderDemo
//
//  Created by Owen Thomas on 12/5/18.
//  Copyright © 2018 SwiftCoders. All rights reserved.
//

import UIKit

class CarViewController: UIViewController {
  var viewModel: CarViewModel!
  @IBOutlet weak var providerLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
  @IBOutlet weak var transmissionLabel: UILabel!
  @IBOutlet weak var airConditioningLabel: UILabel!
  @IBOutlet weak var fuelLabel: UILabel!
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    providerLabel.text = viewModel.car.providerName
    typeLabel.text = viewModel.car.type
    transmissionLabel.text = viewModel.car.transmission
    airConditioningLabel.text = viewModel.airConditioning
    fuelLabel.text = viewModel.car.fuel
    costLabel.text = viewModel.car.estimatedTotal?.currencyString
    categoryLabel.text = viewModel.car.category
    addressLabel.text = "\(viewModel.car.address.line1) \(viewModel.car.address.city) \(viewModel.car.address.country) "
  }
}
