//
//  MoreOrderInfoVC.swift
//  Taxy
//
//  Created by iosdev on 29.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation

class MoreOrderInfoVC: UITableViewController {
    var order: Order? = .None
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let order = self.order else {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        configureView(order)
    }
    
    func configureView(order: Order) {
        if let price = order.price {
            priceLabel.text = String(price) + "руб"
        }
        fromLabel.text = order.fromPlace 
        toLabel.text = order.toPlace

        
    }
    
}