//
//  FormSegmentedCellNoTitle.swift
//  Taxy
//
//  Created by Artem Valiev on 08.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import Former

public class FormSegmentedCellNoTitle: FormSegmentedCell {
    
    public override func formTitleLabel() -> UILabel? {
        return titleLabel
    }
    
    public override func formSegmented() -> UISegmentedControl {
        return segmentedControl
    }
    
    public override func setup() {
        super.setup()

        let constraints = [
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[segment(30)]",
                options: [],
                metrics: nil,
                views: ["segment": segmentedControl]
            ),
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-15-[segment(>=0)]-15-|",
                options: [],
                metrics: nil,
                views: ["segment": segmentedControl]
            )
            ].flatMap { $0 }
        let centerYConst = NSLayoutConstraint(
            item: segmentedControl,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0
        )
        contentView.addConstraints(constraints + [centerYConst])
    }
    
}