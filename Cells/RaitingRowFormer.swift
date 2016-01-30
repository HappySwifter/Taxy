//
//  ButtonsRowFormer.swift
//  Taxy
//
//  Created by iosdev on 15.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import Former

public final class RaitingRowFormer<T: UITableViewCell>
: BaseRowFormer<T>, Formable {
    
    // MARK: Public
    
    public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: (T -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }

    
    public override func cellInitialized(cell: T) {
        super.cellInitialized(cell)

    }
    
    public override func update() {
        super.update()
    }
    
    public override func cellSelected(indexPath: NSIndexPath) {
        former?.deselect(true)
    }

}