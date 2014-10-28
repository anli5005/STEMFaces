//
//  FaceCardViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/25/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class FaceCardViewController: UICollectionViewController {
    
    weak var parentController: DetailViewController!
    var detailItem: Int? {
        didSet {
            configureView()
        }
    }
    
    var imageList = [String]()
    
    var editMode = false
    
    weak var nameField: UITextField!
    weak var aboutField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        if let detail = detailItem {
            navigationItem.title = (parentController.faces[detail]["name"] as String)
        }
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "toggleEditMode")
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        collectionView.reloadData()
    }
    
    func configureView() {
        if let setName = parentController.detailItem as? String {
            if let detail = detailItem {
                let setFolder = docPath.stringByAppendingPathComponent(setName)
                let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(parentController.faces[detail]["id"] as Int))
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
                imageList = sorted(items) { (in1: String, in2: String) in
                    return in1.stringByDeletingPathExtension.toInt()! < in2.stringByDeletingPathExtension.toInt()!
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleEditMode() {
        editMode = !editMode
        for textField in [nameField, aboutField] {
            textField.enabled = editMode
            textField.borderStyle = editMode ? .RoundedRect : .None
        }
        let editButton = UIBarButtonItem(barButtonSystemItem: (editMode ? .Done : .Edit), target: self, action: "toggleEditMode")
        navigationItem.rightBarButtonItem = editButton
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let detail = detailItem {
            var face = parentController.faces[detail]
            face["name"] = nameField.text
            face["about"] = aboutField.text
            parentController.faces[detail] = face
        }
    }
    
    func insertNewImage(sender: AnyObject) {
        // Initialize a UIAlertController
        let promptControl = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        promptControl.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        promptControl.addAction(UIAlertAction(title: "Browse Photo Library", style: UIAlertActionStyle.Default, handler: {
            (alertAction: UIAlertAction!) in
            
        }))
        presentViewController(promptControl, animated: true, completion: {})
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parentController.faces.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?
        
        return (collectionView.dequeueReusableCellWithReuseIdentifier("Face Image", forIndexPath: indexPath) as UICollectionViewCell)
        
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            if kind == UICollectionElementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Face Header", forIndexPath:indexPath) as HeaderCollectionReusableView
                nameField = view.nameField
                aboutField = view.aboutField
                if let detail = detailItem {
                    let face = parentController.faces[detail]
                    let name = (face["name"] as String)
                    let about = (face["about"] as String)
                    
                    nameField.text = name
                    aboutField.text = about
                }
                nameField.enabled = editMode
                aboutField.enabled = editMode
                return view
            } else {
                let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Button Cell", forIndexPath:indexPath) as ButtonCollectionReusableView
                view.addButton.addTarget(self, action: "insertNewImage:", forControlEvents: .TouchUpInside)
                view.deleteButton.addTarget(self, action: "deleteFace:", forControlEvents: .TouchUpInside)
                return view
            }
    }
    
    func deleteFace(sender: AnyObject) {
        
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}
