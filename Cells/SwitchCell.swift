//
//  EmptyCell.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import DGRunkeeperSwitch

protocol SwitchDelegate: class {
    func switchChanged(index: Int)
}

final class SwitchCell: SideDrawerTableViewCell {
    weak var delegate: SwitchDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
    }
    
    func configure() {
        let runkeeperSwitch = DGRunkeeperSwitch(leftTitle: "Свободен", rightTitle: "Занят")
        runkeeperSwitch.backgroundColor = UIColor.mainOrangeColor()
        runkeeperSwitch.selectedBackgroundColor = .whiteColor()
        runkeeperSwitch.titleColor = .whiteColor()
        runkeeperSwitch.selectedTitleColor = UIColor.mainOrangeColor()
        runkeeperSwitch.titleFont = UIFont.light_Med()
        runkeeperSwitch.frame = CGRect(x: 10.0, y: 5, width: 200.0, height: 30.0)
        runkeeperSwitch.addTarget(self, action: Selector("switchValueDidChange:"), forControlEvents: .ValueChanged)
        runkeeperSwitch.selected = Bool(UserProfile.sharedInstance.driverState.hashValue - 1)
        
        addSubview(runkeeperSwitch)
    }
    
    func switchValueDidChange(sender: DGRunkeeperSwitch!) {
        print("valueChanged: \(sender.selectedIndex)")
        delegate?.switchChanged(sender.selectedIndex)
    }
  
}
