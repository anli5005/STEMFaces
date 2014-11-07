//
//  BorderButton.swift
//  Faces
//
//  Created by Anthony Li on 11/7/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class BorderButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5)
        titleColorForState(.Normal)!.setStroke()
        path.stroke()
    }

}
