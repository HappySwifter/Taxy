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

    // passenger
    @IBOutlet weak var passName: UILabel!
    @IBOutlet weak var passPhone: UILabel!
    
    
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
            raitingView.userInteractionEnabled = false
//            raitingView.backgroundColor = .grayColor()
            driverRaitingView.addSubview(raitingView)
        } else {
            noRaitingLabel.hidden = false
            driverRaitingView.hidden = true
        }
        
        driverName.text = driverInfo.name ?? ""
        driverPhoto.backgroundColor = .whiteColor()
        driverCarPhoto.backgroundColor = .whiteColor()

        
        if let image = driverInfo.image {
            driverPhoto.image = image
            driverPhoto.contentMode = .ScaleAspectFit

        } else {
            driverPhoto.image = UIImage(named: "icon_menu_name.png")
            driverPhoto.image? = (driverPhoto.image?.imageWithRenderingMode(.AlwaysTemplate))!
            driverPhoto.tintColor = UIColor.grayColor()
        }
        
        if let carPhoto = driverInfo.carPhoto {
            driverCarPhoto.image = carPhoto
            driverPhoto.contentMode = .ScaleAspectFit

        } else {
            driverCarPhoto.image = UIImage(named: "ic_service_small_regular.png")
            driverCarPhoto.image? = (driverCarPhoto.image?.imageWithRenderingMode(.AlwaysTemplate))!
            driverCarPhoto.tintColor = UIColor.grayColor()
        }
        
        driverCarDesc.text = Helper().getDriverCarInfo(driverInfo)
        if let phone = driverInfo.phoneNumber where phone.characters.count == 10 {
            driverPhone.text = "+7\(phone)"
        } else {
            driverPhone.text = ""
        }
        
        
        // passenger
        passName.text = order.passengerInfo.name ?? ""
        if let phone = order.passengerInfo.phoneNumber where phone.characters.count >= 10 {
            passPhone.text = "+7\(phone)"
        } else {
            passPhone.text = ""
        }
    }
    
}