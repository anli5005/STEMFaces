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
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK:

    let shuffledFaces = sorted(faces) { (face1, face2) in
        return (rand() % 2) == 1
    }
    
    var currentFaceIndex = 0
    var revealed = false
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func stepperChange(sender: UIStepper?) {
        currentFaceIndex = Int(stepper.value)
        refreshData()
    }
    
    @IBAction func sliderChange(sender: UISlider?) {
        currentFaceIndex = Int(round(slider.value))
        refreshData()
    }
    
    @IBAction func reveal(sender: AnyObject?) {
        revealed = !revealed
        refreshData()
    }
    
    func refreshData() {
        stepper.value = Double(currentFaceIndex)
        slider.value  = Float(currentFaceIndex)
        
        numberLabel.text = "Face \(currentFaceIndex + 1) of \(shuffledFaces.count)"
        
        nameLabel.text = revealed ? shuffledFaces[currentFaceIndex]["name"] as String : "?"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        stepper.minimumValue = 0
        slider.minimumValue  = 0
        
        stepper.maximumValue = Double(shuffledFaces.count - 1)
        slider.maximumValue  = Float(shuffledFaces.count  - 1)
        
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
