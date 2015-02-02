//
//  FlashcardViewController.swift
//  Faces
//
//  Created by Anthony Li on 11/7/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class FlashcardViewController: UIViewController {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK:
    
    let shuffledFaces: [[String: AnyObject]] = {
        let f = sorted(faces) { (face1, face2) in
            return (rand() % 2) == 1
        }
        return sorted(f) { (face1, face2) in
            return (rand() % 2) == 1
        }
    }()
    
    var currentFaceIndex: Int = 0 {
        didSet {
            revealed = false
            imageLoaded = false
            refreshData()
        }
    }
    var revealed: Bool = false {
        didSet {
            refreshData()
        }
    }
    
    private var imageLoaded = false
    
    @IBAction func previous(sender: AnyObject?) {
        if currentFaceIndex - 1 >= 0 {
            currentFaceIndex -= 1
        }
    }
    
    @IBAction func next(sender: AnyObject?) {
        if revealed {
            if currentFaceIndex + 1 < shuffledFaces.count {
                currentFaceIndex += 1
            }
        } else {
            revealed = true
        }
    }
    
    func refreshData() {
        numberLabel.text = "\(currentFaceIndex + 1) of \(shuffledFaces.count)"
        
        nameLabel.text = revealed ? shuffledFaces[currentFaceIndex]["name"] as String : "Tap Reveal to reveal the name"
        
        nameLabel.textColor = revealed ? UIColor.blackColor() : UIColor.grayColor()
        
        nameLabel.font = revealed ? nameLabel.font.fontWithSize(36) : nameLabel.font.fontWithSize(18)
        
        aboutLabel.text = (shuffledFaces[currentFaceIndex]["about"] as String)
        
        if !imageLoaded {
            if let setName = nameOfSet {
                let setFolder = docPath().stringByAppendingPathComponent(setName)
                let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(shuffledFaces[currentFaceIndex]["id"] as Int))
                let fileManager = NSFileManager.defaultManager()
                if !fileManager.fileExistsAtPath(imageFolder) {
                    // Make the folder
                    fileManager.createDirectoryAtPath(imageFolder, withIntermediateDirectories: false, attributes: nil, error: nil)
                }
                var items = [String]()
                for item in (fileManager.contentsOfDirectoryAtPath(imageFolder, error: nil) as [String]) {
                    if !item.hasPrefix(".") && item.stringByDeletingPathExtension.toInt() != nil {
                        items.append(item)
                    }
                }
                let imageList = sorted(items) { (in1: String, in2: String) in
                    return (rand() % 2) == 1
                }
                if let imageFile = imageList.first {
                    imageView.image = UIImage(contentsOfFile: imageFolder.stringByAppendingPathComponent(imageFile))
                    imageLoaded = true
                } else {
                    imageView.image = nil
                }
            }
        }
        
        previousButton.enabled = currentFaceIndex - 1 >= 0
        
        nextButton.enabled = revealed ? (currentFaceIndex + 1 < shuffledFaces.count) : true
        nextButton.setTitle(revealed ? "Next" : "Reveal", forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
