//
//  PlayView.swift
//  Face Cards
//
//  Created by Anthony Li on 11/12/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class PlayView: UIView {
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Path creation
        let theCGPath = CGPathCreateMutable()
        CGPathMoveToPoint(theCGPath, nil, 10, 5)
        CGPathAddLineToPoint(theCGPath, nil, 10, 25)
        CGPathAddLineToPoint(theCGPath, nil, 25, 15)
        CGPathAddLineToPoint(theCGPath, nil, 10, 5)
        let bezierPath = UIBezierPath(CGPath: theCGPath)
        
        // Drawing phase 1
        UIColor.blackColor().setFill()
        UIRectFill(rect)
        UIColor.whiteColor().setFill()
        bezierPath.fill()
        
        // Drawing phase 2
        let string = "Play"
        string.drawAtPoint(CGPoint(x: 30, y: 5), withAttributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 18)!])
    }
}
