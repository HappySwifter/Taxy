//
//  EmptyCell.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    func configure() {
        nameLabel.textColor = .whiteColor()
        phoneLabel.textColor = .whiteColor()
        nameLabel.font = .bold_Med()
        phoneLabel.font = .bold_Med()
        
        photoView.contentMode = .ScaleAspectFit
        photoView.image = UserProfile.sharedInstance.image ?? UIImage(named: "placeholderImage.jpg")
        nameLabel.text = UserProfile.sharedInstance.name ?? ""
        phoneLabel.text = UserProfile.sharedInstance.phoneNumber ?? ""
    }
}


class SideDrawerTableViewCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        textLabel?.font = .light_Lar()
        textLabel?.textColor = .whiteColor()
    }

}
