//
//  DetailViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/19/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var faces = [[String: AnyObject]]()
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem as? String {
            let fileManager = NSFileManager.defaultManager() // For easy access
            let setFolder = docPath.stringByAppendingPathComponent(detail)
            // Check for image folder
            var isDir: ObjCBool = false
            var exists = fileManager.fileExistsAtPath(setFolder.stringByAppendingPathComponent("Images"), isDirectory: &isDir)
            if !isDir && exists {
                fileManager.removeItemAtPath(setFolder.stringByAppendingPathComponent("Images"), error: nil)
                exists = false
            }
            if !exists {
                fileManager.createDirectoryAtPath(setFolder.stringByAppendingPathComponent("Images"), withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            
            navigationItem.title = detail
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view,
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject() {
        if let detail = detailItem as? String {
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let detail = detailItem as? String {
            var error: NSError?
            var data = NSJSONSerialization.dataWithJSONObject(faces, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            if let e = error { println("Error making data: \(e.localizedDescription)") }
            data?.writeToFile(docPath.stringByAppendingPathComponent(detail).stringByAppendingPathComponent("Data.json"), atomically: true)
        }
    }
    
    
}

