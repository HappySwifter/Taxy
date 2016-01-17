//
//  RateVC.swift
//  Taxy
//
//  Created by iosdev on 15.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit
import CNPPopupController
import HCSStarRatingView



protocol Rateble: CNPPopupControllerDelegate {
    func presentRate()
}

extension Rateble where Self:UIViewController {
    func presentRate() {
        
        var popupController = CNPPopupController()

        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let title = NSAttributedString(string: "Вы можете оценить водителя", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(24), NSParagraphStyleAttributeName: paragraphStyle])
        
        let button = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 60))
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        button.setTitle("Закрыть", forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        
        button.layer.cornerRadius = 4;
        button.selectionHandler = { _ in
            popupController.dismissPopupControllerAnimated(true)
        }
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        
        let imageView = UIImageView.init(image: UIImage.init(named: "icon"))
        
        let customView = UIView.init(frame: CGRectMake(0, 0, 250, 55))
        customView.backgroundColor = UIColor.lightGrayColor()
        
        
        let starRatingView = HCSStarRatingView(frame: customView.frame)
        starRatingView.maximumValue = 5
        starRatingView.minimumValue = 0
        starRatingView.value = 0
        starRatingView.tintColor = UIColor.greenColor()
        starRatingView.addTarget(self, action: "didRate:", forControlEvents: .ValueChanged)
        customView.addSubview(starRatingView)
        
        
        popupController = CNPPopupController(contents:[titleLabel, imageView, customView, button])
        popupController.theme = CNPPopupTheme.defaultTheme()
        popupController.theme.popupStyle = CNPPopupStyle.Centered
        popupController.delegate = self
        popupController.presentPopupControllerAnimated(true)
    }
}
