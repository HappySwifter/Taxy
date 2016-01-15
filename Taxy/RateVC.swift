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


class RateVC: UIViewController {

    var popupController:CNPPopupController = CNPPopupController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showPopupWithStyle(CNPPopupStyle.Centered)
    }

    func showPopupWithStyle(popupStyle: CNPPopupStyle) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let title = NSAttributedString(string: "Вы можете оценить водителя", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(24), NSParagraphStyleAttributeName: paragraphStyle])
//        let lineOne = NSAttributedString(string: "You can add text and images", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18), NSParagraphStyleAttributeName: paragraphStyle])
//        let lineTwo = NSAttributedString(string: "With style, using NSAttributedString", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18), NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0), NSParagraphStyleAttributeName: paragraphStyle])
        
        let button = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 60))
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        button.setTitle("Закрыть", forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        
        button.layer.cornerRadius = 4;
        button.selectionHandler = { [weak self] button in
            self?.popupController.dismissPopupControllerAnimated(true)
            print("Block for button: \(button.titleLabel?.text)")
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
        starRatingView.addTarget(self, action: "didChangeValue:", forControlEvents: .ValueChanged)
        customView.addSubview(starRatingView)

        
        self.popupController = CNPPopupController(contents:[titleLabel, imageView, customView, button])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = popupStyle
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }


    
    func didChangeValue(value: AnyObject) {
        print(value)
    }

}

extension RateVC : CNPPopupControllerDelegate {
    
    func popupController(controller: CNPPopupController, dismissWithButtonTitle title: NSString) {
        self.popupController.delegate = nil
        print("Dismissed with button title \(title)")
    }
    
    func popupControllerDidPresent(controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}