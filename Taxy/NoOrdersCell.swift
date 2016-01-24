//
//  NoOrdersCell.swift
//  Taxy
//
//  Created by Artem Valiev on 24.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation

protocol NoOrdersCellDelegate: class {
    func noOrdersCellButtonTouched()
}

class NoOrdersCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customButton: UIButton!
    weak var delegate: NoOrdersCellDelegate?
    
    
    @IBAction func buttonPressed() {
        delegate?.noOrdersCellButtonTouched()
    }
    
    func configureForVC(vc: String) {
        selectionStyle = .None
        customButton.backgroundColor = .mainOrangeColor()
        customButton.titleLabel?.textAlignment = .Center

        if vc == String(MyOrders) {
            if UserProfile.sharedInstance.type == .Passenger {
                customButton.titleLabel?.text = "Создать заказ"
            } else {
                customButton.titleLabel?.text = "Найти заказ"
            }
        } else if vc == String(FindOrders) {
            customButton.titleLabel?.text = "Обновить"
        }
    }
    
}