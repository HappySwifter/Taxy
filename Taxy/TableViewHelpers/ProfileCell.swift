//
//  ProfileCell.swift
//  Taxy
//
//  Created by Artem Valiev on 16.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation

class ProfileCell: SideDrawerTableViewCell {
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(userInfo: UserProfile) {
        if let image = userInfo.image {
            photoView.image = image
        } else {
            
        }
    }
}