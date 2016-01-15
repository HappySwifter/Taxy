//
//  ButtonsRowFormer.swift
//  Taxy
//
//  Created by iosdev on 15.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import Former

public protocol ButtonsFormableRow: FormableRow {
    
    func formButton1() -> UIButton
    func formButton2() -> UIButton
//    func formTitleLabel() -> UILabel?
}

public final class ButtonsRowFormer<T: UITableViewCell where T: ButtonsFormableRow>
: BaseRowFormer<T>, Formable {
    
    // MARK: Public
    
    public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: (T -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    public final func onButtonPressed(handler: (Int -> Void)) -> Self {
        onButtonPressed = handler
        return self
        
    }
    
    public override func cellInitialized(cell: T) {
        super.cellInitialized(cell)
        cell.formButton1().addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        cell.formButton2().addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)

    }
    
    public override func update() {
        super.update()
    }
    
    public override func cellSelected(indexPath: NSIndexPath) {
        former?.deselect(true)
    }
    
    // MARK: Private
    
    private final var onButtonPressed: (Int -> Void)?
    
    private dynamic func buttonPressed(button: UIButton) {
        if self.enabled {
            onButtonPressed?(button.tag)
        }
    }
}