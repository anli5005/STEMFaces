//
//  MatchingCollectionViewCell.swift
//  Face Cards
//
//  Created by Anthony Li on 1/23/15.
//  Copyright (c) 2015 anli5005. All rights reserved.
//

import UIKit

private let matchingStatusMessages: [String: (String, UIColor)] = [
    "nothing":   ("",            UIColor.blackColor()),
    "selected":  ("✓",           UIColor.blueColor()),
    "incorrect": ("✕ Incorrect", UIColor.redColor()),
    "correct":   ("✓ Correct",   UIColor(red: 0, green: 176 / 255, blue: 0, alpha: 1))
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
        self.userCorrect = nil
        self.updateStatusLabel()
    }
    
    func updateStatusLabel() {
        // 1. If the user is correct or incorrect...
        var status: (String, UIColor)
        if let correct = self.userCorrect {
            // 1a. ...update the status.
            status = matchingStatusMessages[correct ? "correct" : "incorrect"]!
        } else {
            // 1b. If the cell's selected, update the status.
            status = matchingStatusMessages[self.elementSelected ? "selected" : "nothing"]!
        }
        // 2. Apply the status to the label.
        self.statusLabel.text = status.0
        self.statusLabel.textColor = status.1
    }
}