// Copyright (c) 2014 evolved.io (http://evolved.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

private class DisclosureIndicator: UIView {
    var color: UIColor = UIColor.whiteColor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let chevronColor = self.color
        let frame = self.bounds
        
        let chevronPath = UIBezierPath()
        chevronPath.moveToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.22000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.01667 * CGRectGetHeight(frame)))
        chevronPath.addLineToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.98000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.48333 * CGRectGetHeight(frame)))
        chevronPath.addLineToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.22000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.98333 * CGRectGetHeight(frame)))
        chevronPath.addLineToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.02000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.81667 * CGRectGetHeight(frame)))
        chevronPath.addLineToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.54000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.48333 * CGRectGetHeight(frame)))
        chevronPath.addLineToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.02000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.15000 * CGRectGetHeight(frame)))
        chevronPath.addLineToPoint(CGPoint(x: CGRectGetMinX(frame) + 0.22000 * CGRectGetWidth(frame), y: CGRectGetMinY(frame) + 0.01667 * CGRectGetHeight(frame)))
        chevronPath.closePath()
        
        CGContextSaveGState(context)
        chevronColor.setFill()
        chevronPath.fill()
        CGContextRestoreGState(context)
    }
}



class TableViewCell: UITableViewCell {
    var accessoryCheckmarkColor: UIColor = UIColor.whiteColor()
    var disclosureIndicatorColor: UIColor = UIColor.whiteColor()
    override var accessoryType: UITableViewCellAccessoryType {
        didSet {
             if self.accessoryType == .DisclosureIndicator {
                let di = DisclosureIndicator(frame: CGRect(x: 0, y: 0, width: 10, height: 14))
                di.color = self.disclosureIndicatorColor
                self.accessoryView = di
            } else {
                self.accessoryView = nil
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.updateContentForNewContentSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.updateContentForNewContentSize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.updateContentForNewContentSize()
    }
    
    func updateContentForNewContentSize() {
        
    }
}
