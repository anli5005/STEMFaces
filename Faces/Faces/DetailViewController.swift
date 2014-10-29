//
//  DetailViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/19/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class DetailViewController: UICollectionViewController {
    
    var faces = [[String: AnyObject]]()
    private var setLoaded = false
    
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
            
            if !setLoaded && fileManager.fileExistsAtPath(setFolder.stringByAppendingPathComponent("Data.json")) {
                // Load the face data
                if let data = NSData(contentsOfFile: setFolder.stringByAppendingPathComponent("Data.json")) {
                    var error: NSError?
                    if let jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as? [[String: AnyObject]] {
                        faces = jsonObject
                    } else {
                        println("Error parsing data: \(error!.localizedDescription)")
                    }
                }
            }
            setLoaded = true
            
            navigationItem.title = detail
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add Add button
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject")
        self.navigationItem.rightBarButtonItem = addButton
        // Do any additional setup after loading the view
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject() {
        if let detail = detailItem as? String {
            // Make a face object
            var face = [String: AnyObject]()
            // Get a face ID
            if let lastFace = faces.last {
                let lastId = lastFace["id"] as Int
                face["id"] = lastId + 1
            } else {
                face["id"] = 0
            }
            // Set default face details
            face["name"] = "Person"
            face["about"] = ""
            // Add face to face array
            faces.append(face)
            // Reload collection view
            collectionView.reloadData()
            /* An automatic segue to face editing scene will be implemented soon.
            For now, the user can tap to edit the new face.
            */
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let detail = detailItem as? String {
            var error: NSError?
            var data = NSJSONSerialization.dataWithJSONObject(faces, options: .PrettyPrinted, error: &error)
            if let e = error { println("Error making data: \(e.localizedDescription)") }
            data?.writeToFile(docPath.stringByAppendingPathComponent(detail).stringByAppendingPathComponent("Data.json"), atomically: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier ?? "") == "showCard" {
            let dest = (segue.destinationViewController as UINavigationController).topViewController as FaceCardViewController
            dest.parentController = self
            dest.detailItem = (sender as NSIndexPath).row
        }
    }
    
    // MARK: Collection View Controller
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faces.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Face Card", forIndexPath: indexPath) as FaceCardCollectionViewCell
        
        // Configure the cell with the face details.
        let face = faces[indexPath.item]
        cell.label?.text = (face["name"] as String)
        
        // Setup the image
        if let detail = detailItem as? String {
            let setFolder = docPath.stringByAppendingPathComponent(detail)
            let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(face["id"] as Int))
            let imagePath = imageFolder.stringByAppendingPathComponent("0.png")
            cell.image?.image = UIImage(contentsOfFile: imagePath)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Perform the segue
        performSegueWithIdentifier("showCard", sender: indexPath)
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Detail Footer", forIndexPath:indexPath) as DetailFooterCollectionReusableView
            return view
    }
    
}

