//
//  QuizController.swift
//  Faces
//
//  Created by Anthony Li on 11/6/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class QuizController: UIViewController {
    
    let textField = UITextField()
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
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
