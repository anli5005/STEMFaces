//
//  ReviewViewController.swift
//  Faces
//
//  Created by Anthony Li on 11/7/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    // MARK: Interface Builder Outlets
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
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
    
    private var imageLoaded = false
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func stepperChange(sender: UIStepper?) {
        currentFaceIndex = Int(stepper.value)
    }
    
    @IBAction func reveal(sender: AnyObject?) {
        revealed = !revealed
    }
    
    func refreshData() {
        stepper.value = Double(currentFaceIndex)
        
        numberLabel.text = "Face \(currentFaceIndex + 1) of \(shuffledFaces.count)"
        
        nameLabel.text = revealed ? shuffledFaces[currentFaceIndex]["name"] as String : "?"
        
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        stepper.minimumValue = 0
        stepper.maximumValue = Double(shuffledFaces.count - 1)
        
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
