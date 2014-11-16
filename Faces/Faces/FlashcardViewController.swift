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
    
    @IBOutlet weak var showsNameSegments: UISegmentedControl!
    
    // MARK:
    
    let shuffledFaces = sorted(faces) { (face1, face2) in
        return (rand() % 2) == 1
    }
    
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
    
    var alwaysShowName: Bool = true {
        didSet {
            refreshData()
        }
    }
    
    private var imageLoaded = false
    
    @IBAction func updateAlwaysShowsName(sender: UISegmentedControl?) {
        if let theSender = sender {
            switch theSender.selectedSegmentIndex {
            case 0:
                alwaysShowName = true
            case 1:
                alwaysShowName = false
            default:
                assert(false, "Unexpected value for selected segment: " + String(theSender.selectedSegmentIndex))
            }
        }
    }
    
    @IBAction func previous(sender: AnyObject?) {
        if currentFaceIndex - 1 >= 0 {
            currentFaceIndex -= 1
        }
    }
    
    @IBAction func next(sender: AnyObject?) {
        if alwaysShowName {
            if currentFaceIndex + 1 < shuffledFaces.count {
                currentFaceIndex += 1
            }
        } else {
            if revealed {
                if currentFaceIndex + 1 < shuffledFaces.count {
                    currentFaceIndex += 1
                }
            } else {
                revealed = true
            }
        }
    }
    
    func refreshData() {
        numberLabel.text = "\(currentFaceIndex + 1) of \(shuffledFaces.count)"
        
        nameLabel.text = revealed || alwaysShowName ? shuffledFaces[currentFaceIndex]["name"] as String : "Tap Reveal to reveal the name"
        
        nameLabel.textColor = !(revealed || alwaysShowName) ? UIColor.grayColor() : UIColor.blackColor()
        
        nameLabel.font = (!(revealed || alwaysShowName) && currentFaceIndex < 1) ? nameLabel.font.fontWithSize(18) : nameLabel.font.fontWithSize(36)
        
        aboutLabel.text = (shuffledFaces[currentFaceIndex]["about"] as String)
        
        if !imageLoaded {
            if let setName = nameOfSet {
                let setFolder = docPath.stringByAppendingPathComponent(setName)
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
        
        nextButton.enabled = (alwaysShowName || revealed) ? (currentFaceIndex + 1 < shuffledFaces.count) : true
        nextButton.setTitle((alwaysShowName || revealed) ? "Next" : "Reveal", forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        showsNameSegments.setWidth(100, forSegmentAtIndex: 0)
        showsNameSegments.setWidth(100, forSegmentAtIndex: 1)
        
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
