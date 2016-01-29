//
//  MoreOrderInfoVC.swift
//  Taxy
//
//  Created by iosdev on 29.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import HCSStarRatingView

class MoreOrderInfoVC: UITableViewController {
    var order: Order? = .None
    let raitingView = HCSStarRatingView(frame: CGRectZero)
    // order
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    // driver
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var driverPhoto: UIImageView!
    @IBOutlet weak var driverCarPhoto: UIImageView!
    @IBOutlet weak var driverCarDesc: UILabel!
    @IBOutlet weak var driverPhone: UILabel!
    @IBOutlet weak var driverRaitingView: UIView!
    @IBOutlet weak var noRaitingLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let order = self.order else {
            navigationController?.popViewControllerAnimated(true)
            return
        }
        configureView(order)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        raitingView.frame = driverRaitingView.bounds
        raitingView.layoutIfNeeded()
    }
    
    func configureView(order: Order) {
        // order
        if let price = order.price {
            priceLabel.text = String(price) + " руб"
        }
        fromLabel.text = order.fromPlace 
        toLabel.text = order.toPlace

        
        // driver
        let driverInfo = order.driverInfo
        if let raiting = driverInfo.raiting where raiting > 0  {
            noRaitingLabel.hidden = true
            driverRaitingView.hidden = false
            
            driverRaitingView.backgroundColor = .whiteColor()
            raitingView.allowsHalfStars = true
            raitingView.value =  CGFloat.init(raiting)
            raitingView.spacing = 1
            raitingView.tintColor = UIColor.greenColor()
            raitingView.backgroundColor = .grayColor()
            driverRaitingView.addSubview(raitingView)
        } else {
            noRaitingLabel.hidden = false
            driverRaitingView.hidden = true
        }
        
        driverName.text = driverInfo.name ?? ""
        driverPhoto.image = driverInfo.image ?? UIImage(named: "placeholderImage.jpg")
        driverCarPhoto.image = driverInfo.carPhoto ?? UIImage(named: "car-placeholder-eservice.png")
        driverCarDesc.text = Helper().getDriverCarInfo(driverInfo)
        if let phone = driverInfo.phoneNumber where phone.characters.count == 10 {
            driverPhone.text = "+7\(phone)"
        } else {
            driverPhone.text = ""
        }
        

    }
    
}