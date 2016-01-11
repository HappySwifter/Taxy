//
//  RulesVC.swift
//  Taxy
//
//  Created by Artem Valiev on 14.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit

final class RulesVC: UIViewController {
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var passengerView: UIView?
    @IBOutlet weak var driverView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Правила"
        configure()

    }
    
    private func configure() {
        switch mySegmentedControl.selectedSegmentIndex {
        case 0:
            passengerView?.hidden = false
            driverView?.hidden = true
        case 1:
            passengerView?.hidden = true
            driverView?.hidden = false
        default:
            break
        }
    }
    
    @IBAction func segmControlChanged() {
        configure()
    }

}