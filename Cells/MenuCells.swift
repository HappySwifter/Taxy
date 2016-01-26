//
//  EmptyCell.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import DGRunkeeperSwitch

final class SwitchCell: SideDrawerTableViewCell {
    
    func configure() {
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
        selectionStyle = .None
        let runkeeperSwitch = DGRunkeeperSwitch(leftTitle: "Свободен", rightTitle: "Занят")
        runkeeperSwitch.backgroundColor = .whiteColor()
        runkeeperSwitch.selectedBackgroundColor = .mainOrangeColor()
        runkeeperSwitch.titleColor = .mainOrangeColor()
        runkeeperSwitch.selectedTitleColor = .whiteColor()
        runkeeperSwitch.titleFont = UIFont.bold_Med()
        runkeeperSwitch.frame = CGRect(x: 10.0, y: 5, width: 200.0, height: 30.0)
        runkeeperSwitch.addTarget(self, action: Selector("switchValueDidChange:"), forControlEvents: .ValueChanged)
        runkeeperSwitch.setSelectedIndex(UserProfile.sharedInstance.driverState.rawValue, animated: false)
        addSubview(runkeeperSwitch)
    }
}




class ProfileCell: SideDrawerTableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    func configure() {
        
        backgroundColor = .clearColor()
        contentView.backgroundColor = .clearColor()
        
        nameLabel.textColor = .lightGrayColor()
        phoneLabel.textColor = .lightGrayColor()
        photoView.contentMode = .ScaleAspectFit

        photoView.image = UserProfile.sharedInstance.image ?? UIImage(named: "placeholderImage.jpg")
        nameLabel.text = UserProfile.sharedInstance.name ?? ""
        phoneLabel.text = UserProfile.sharedInstance.phoneNumber ?? ""
    }
}
