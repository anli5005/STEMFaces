//
//  MatchingCollectionViewCell.swift
//  Face Cards
//
//  Created by Anthony Li on 1/23/15.
//  Copyright (c) 2015 anli5005. All rights reserved.
//

import UIKit

private let matchingStatusMessages: [String: (String, UIColor, Bool)] = [
    "nothing":   ("",            UIColor.blackColor(), false),
    "selected":  ("✓",           UIColor.blueColor(), false),
    "incorrect": ("✕ Incorrect", UIColor.redColor(), false),
    "correct":   ("✓ Correct",   UIColor(red: 0, green: 176 / 255, blue: 0, alpha: 1), true)
]

class MatchingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var labelView: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var personId: Int? = nil
    
    var elementSelected: Bool = false {
        didSet {
            self.updateStatusLabel()
        }
    }
    var elementDisabled: Bool = false
    var userCorrect: Bool? = nil {
        didSet {
            self.updateStatusLabel()
        }
    }
    
    enum MatchingCellType {
        case Image
        case Text
        case Unknown
    }
    
    func getCellType() -> MatchingCellType {
        if self.imageView != nil {
            return .Image
        } else if self.labelView != nil {
            return .Text
        } else {
            return .Unknown
        }
    }
    
    func refreshFaceData() {
        if self.getCellType() == .Text {
            if let id = personId {
                let face = faces[id]
                self.labelView!.text = (face["name"] as String)
            } else {
                self.labelView!.text = ""
            }
        } else if self.getCellType() == .Unknown {
            assertionFailure("Unknown cell type")
        }
        self.updateStatusLabel()
    }
    
    func hideUserScore(sender: AnyObject?) { // I don't care about sender; it's just for the NSTimer
        if self.userCorrect != true {
            self.userCorrect = nil
        }
        self.updateStatusLabel()
    }
    
    func updateStatusLabel() {
        var status: (String, UIColor, Bool)
        if let correct = self.userCorrect {
            if correct {
                status = matchingStatusMessages["correct"]!
            } else {
                status = matchingStatusMessages[self.elementSelected ? "selected" : "incorrect"]!
            }
        } else {
            status = matchingStatusMessages[self.elementSelected ? "selected" : "nothing"]!
        }
        // Apply the status to the label.
        self.statusLabel.text = status.0
        self.statusLabel.textColor = status.1
        self.statusLabel.font = status.2 ? UIFont.boldSystemFontOfSize(18) : UIFont.systemFontOfSize(18)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let path = UIBezierPath(rect: rect)
        UIColor.blackColor().setStroke()
        path.stroke()
    }
}