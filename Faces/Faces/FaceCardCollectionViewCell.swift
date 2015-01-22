//
//  FaceCardCollectionViewCell.swift
//  Faces
//
//  Created by Anthony Li on 10/25/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

private class FaceCardTextOverlay: UIView {
    var text: String? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // Draw text
        if let t = text {
            let s = NSShadow()
            s.shadowOffset = CGSize(width: 5, height: 5)
            s.shadowBlurRadius = 10
            let f = UIFont(name: "Helvetica Neue", size: 16)
            let c = UIColor.whiteColor()
            var attr = [String: AnyObject]()
            attr[NSShadowAttributeName!] = s
            attr[NSForegroundColorAttributeName!] = c
            attr[NSFontAttributeName!] = f
            let a = NSAttributedString(string: t, attributes: attr)
            
            let w = a.size().width
            let h = a.size().height
            let x = CGRectGetMidX(rect) - (w / 2)
            let y = CGRectGetMaxY(rect) - h - 5
            let r = CGRect(x: x, y: y, width: w, height: h)
            a.drawInRect(r)
        }
    }
}

class FaceCardCollectionViewCell: UICollectionViewCell {
    var text: String? {
        didSet {
            overlayView?.text = self.text
        }
    }
    var image: UIImage? {
        get {
            return imageView?.image
        } set {
            imageView?.image = newValue
        }
    }
    
    var imageView: UIImageView?
    private var overlayView: FaceCardTextOverlay?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView              = UIImageView(frame: self.frame)
        self.backgroundView         = self.imageView
        self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.overlayView = FaceCardTextOverlay(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size))
        self.overlayView!.backgroundColor = UIColor.clearColor()
        self.addSubview(self.overlayView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size)
    }
}
