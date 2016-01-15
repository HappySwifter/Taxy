//
//  ProfileLabelCell.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import Former

final class TwoButtonsCell: UITableViewCell, ButtonsFormableRow {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        button1.tag = 0
        button2.tag = 1
        button1.tintColor = .formerSubColor()
        button2.tintColor = .formerSubColor()
        button1.titleLabel?.font = UIFont.light_Small()
        button2.titleLabel?.font = UIFont.light_Small()
    }
    
    func formButton1() -> UIButton {
        return button1
    }
    func formButton2() -> UIButton {
        return button2
    }
    func updateWithRowFormer(rowFormer: RowFormer) {}
}