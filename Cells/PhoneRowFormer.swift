//
//  PhoneRowFormer.swift
//  Taxy
//
//  Created by iosdev on 30.01.16.
//  Copyright © 2016 ltd Elektronnie Tehnologii. All rights reserved.
//

import UIKit
import Former

public protocol PhoneFormableRow: FormableRow {
    func myPhoneTextField() -> UITextField
}

public final class PhoneRowFormer<T: UITableViewCell where T: PhoneFormableRow>
: BaseRowFormer<T>, Formable {
    

    
    override public var canBecomeEditing: Bool {
        return enabled
    }
    
    public var text: String?
    public var placeholder: String?
    public var attributedPlaceholder: NSAttributedString?
    public var textDisabledColor: UIColor? = .lightGrayColor()
    public var titleDisabledColor: UIColor? = .lightGrayColor()
    public var titleEditingColor: UIColor?
    public var returnToNextRow = true
    
    // MARK: Public
    

    public required init(instantiateType: Former.InstantiateType = .Class, cellSetup: (T -> Void)? = nil) {
        super.init(instantiateType: instantiateType, cellSetup: cellSetup)
    }
    
    public final func onTextChanged(handler: (String -> Void)) -> Self {
        onTextChanged = handler
        return self
    }

    public override func cellInitialized(cell: T) {
        super.cellInitialized(cell)
        let textField = cell.myPhoneTextField()
        let events: [(Selector, UIControlEvents)] = [("textChanged:", .EditingChanged)]
        events.forEach {
            textField.addTarget(self, action: $0.0, forControlEvents: $0.1)
        }
        textField.delegate = observer

    }
    

    
    public override func update() {
        super.update()
        
        cell.selectionStyle = .None
        let textField = cell.myPhoneTextField()
        textField.text = text
        _ = placeholder.map { textField.placeholder = $0 }
        _ = attributedPlaceholder.map { textField.attributedPlaceholder = $0 }
        textField.userInteractionEnabled = false
        
        if enabled {
            if isEditing {
            } else {
                titleColor = nil
            }
            _ = textColor.map { textField.textColor = $0 }
            textColor = nil
        } else {
            textField.textColor = textDisabledColor
        }
    }
    
    public override func cellSelected(indexPath: NSIndexPath) {
        let textField = cell.myPhoneTextField()
        if !textField.editing {
            textField.userInteractionEnabled = true
            textField.becomeFirstResponder()
        }
    }

    
    
    private final var onTextChanged: (String -> Void)?
    private final var textColor: UIColor?
    private final var titleColor: UIColor?
    private lazy var observer: Observer1<T> = Observer1<T>(textFieldRowFormer: self)
    
    
    private dynamic func textChanged(textField: UITextField) {
        if enabled {
            let text = textField.text ?? ""
            self.text = text
            onTextChanged?(text)
        }
    }
    
    private dynamic func editingDidBegin(textField: UITextField) {
//        let titleLabel = cell.formTitleLabel()
        if titleColor == nil { textColor = textField.textColor ?? .blackColor() }
//        _ = titleEditingColor.map { titleLabel?.textColor = $0 }
    }
    
    private dynamic func editingDidEnd(textField: UITextField) {
//        let titleLabel = cell.formTitleLabel()
        if enabled {
//            _ = titleColor.map { titleLabel?.textColor = $0 }
            titleColor = nil
        } else {
//            if titleColor == nil { titleColor = titleLabel?.textColor ?? .blackColor() }
//            _ = titleEditingColor.map { titleLabel?.textColor = $0 }
        }
        cell.myPhoneTextField().userInteractionEnabled = false
    }

}


private class Observer1<T: UITableViewCell where T: PhoneFormableRow>: NSObject, UITextFieldDelegate {
    
    private weak var textFieldRowFormer: PhoneRowFormer<T>?
    
    init(textFieldRowFormer: PhoneRowFormer<T>) {
        self.textFieldRowFormer = textFieldRowFormer
    }
    
    private dynamic func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let textFieldRowFormer = textFieldRowFormer else { return false }
        if textFieldRowFormer.returnToNextRow {
            let returnToNextRow = (textFieldRowFormer.former?.canBecomeEditingNext() ?? false) ?
                textFieldRowFormer.former?.becomeEditingNext :
                textFieldRowFormer.former?.endEditing
            returnToNextRow?()
        }
        return !textFieldRowFormer.returnToNextRow
    }
    
   private dynamic func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        
        let decimalString : String = components.joinWithSeparator("")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        let hasLeadingOne = length > 0 && decimalStr.characterAtIndex(0) == (1 as unichar)
        
        if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
        {
            let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
            
            return (newLength > 10) ? false : true
        }
        var index = 0 as Int
        let formattedString = NSMutableString()
        
        if hasLeadingOne
        {
            formattedString.appendString("1 ")
            index += 1
        }
        if (length - index) > 3
        {
            let areaCode = decimalStr.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("(%@)", areaCode)
            index += 3
        }
        if length - index > 3
        {
            let prefix = decimalStr.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalStr.substringFromIndex(index)
        formattedString.appendString(remainder)
        textField.text = formattedString as String
        NSNotificationCenter.defaultCenter().postNotificationName("phoneNotification", object: textField.text)
        return false
    }
}