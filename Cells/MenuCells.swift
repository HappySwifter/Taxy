//
//  EmptyCell.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import DGRunkeeperSwitch

//protocol SwitchDelegate: class {
//    func switchChanged(index: Int)
//}

final class SwitchCell: SideDrawerTableViewCell {
//    weak var delegate: SwitchDelegate?
    
    func configure() {
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
    
//    func switchValueDidChange(sender: DGRunkeeperSwitch!) {
//        print("valueChanged: \(sender.selectedIndex)")
//        delegate?.switchChanged(sender.selectedIndex)
//    }
}




class ProfileCell: SideDrawerTableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure() {
        nameLabel.textColor = .whiteColor()
        photoView.contentMode = .ScaleAspectFit
        if let image = UserProfile.sharedInstance.image {
            photoView.image = image
        } else {
            photoView.image = UIImage(named: "placeholderImage.jpg")
        }
        if let name = UserProfile.sharedInstance.name {
            nameLabel.text = name
        } else {
            nameLabel.text = ""
        }
    }
}
