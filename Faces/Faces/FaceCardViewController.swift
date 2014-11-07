//
//  FaceCardViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/25/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class FaceCardViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var parentController: DetailViewController!
    var detailItem: Int? {
        didSet {
            configureView()
        }
    }
    
    weak var footerView: ButtonCollectionReusableView!
    
    var imageList = [String]()
    
    var deleted = false
    
    weak var nameField: UITextField!
    weak var aboutField: UITextField!
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        if let detail = detailItem {
            navigationItem.title = (faces[detail]["name"] as String)
        }
        
        self.navigationItem.rightBarButtonItem = editButtonItem()
        
        let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "goBack:")
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func goBack(sender: AnyObject) {
        dismiss()
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
                let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(faces[detail]["id"] as Int))
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        for textField in [nameField, aboutField] {
            textField.enabled = editing
            textField.borderStyle = editing ? .RoundedRect : .None
        }
        footerView?.hidden = !editing
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let detail = detailItem {
            if !deleted {
                var face = faces[detail]
                face["name"] = nameField.text
                face["about"] = aboutField.text
                faces[detail] = face
            }
            parentController?.collectionView.reloadData()
        }
    }
    
    func insertNewImage(sender: AnyObject) {
        // Initialize a UIAlertController
        let promptControl = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        promptControl.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        promptControl.addAction(UIAlertAction(title: "Browse Photo Library", style: UIAlertActionStyle.Default, handler: {
            (alertAction: UIAlertAction!) in
            let controller = UIImagePickerController()
            controller.sourceType = .PhotoLibrary
            controller.delegate = self
            self.presentViewController(controller, animated: true, completion: {})
        }))
        promptControl.popoverPresentationController?.sourceView = footerView.addButton
        presentViewController(promptControl, animated: true, completion: {})
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
            var image: UIImage
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                image = editedImage
            } else {
                image = (info[UIImagePickerControllerOriginalImage] as UIImage)
            }
            var imageName: Int
            if let lastImage = imageList.last {
                let lastImageName = lastImage.stringByDeletingPathExtension
                let lastImageInt = lastImageName.toInt()!
                imageName = lastImageInt + 1
            } else {
                imageName = 0
            }
            if let setName = parentController.detailItem as? String {
                if let detail = detailItem {
                    let setFolder = docPath.stringByAppendingPathComponent(setName)
                    let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(faces[detail]["id"] as Int))
                    UIImagePNGRepresentation(image).writeToFile(imageFolder.stringByAppendingPathComponent("\(imageName).png"), atomically: true)
                    imageList.append("\(imageName).png")
                }
            }
            dismissViewControllerAnimated(true, {})
            collectionView.reloadData()
    }
    
    func deleteFace(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure?", message: "Do you want to delete this face?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        func deleteHandler(action: UIAlertAction!) {
            if let detail = detailItem {
                if let setName = parentController.detailItem as? String {
                    let setFolder = docPath.stringByAppendingPathComponent(setName)
                    let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(faces[detail]["id"] as Int))
                    NSFileManager.defaultManager().removeItemAtPath(imageFolder, error: nil)
                    // Delete the images
                }
                // Delete the face object
                faces.removeAtIndex(detail)
                deleted = true
                // Dismiss controller
                dismiss()
            }
        }
        alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: deleteHandler))
        presentViewController(alertController, animated: true, completion: {})
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCellWithReuseIdentifier("Face Image", forIndexPath: indexPath) as FaceImageCollectionViewCell)
        if let setName = parentController.detailItem as? String {
            if let detail = detailItem {
                let setFolder = docPath.stringByAppendingPathComponent(setName)
                let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(faces[detail]["id"] as Int))
                let filename = imageFolder.stringByAppendingPathComponent(imageList[indexPath.item])
                cell.image?.image = UIImage(contentsOfFile: filename)
            }
        }
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            if kind == UICollectionElementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Face Header", forIndexPath:indexPath) as HeaderCollectionReusableView
                nameField = view.nameField
                aboutField = view.aboutField
                if let detail = detailItem {
                    let face = faces[detail]
                    let name = (face["name"] as String)
                    let about = (face["about"] as String)
                    
                    nameField.text  = name
                    aboutField.text = about
                }
                nameField.enabled  = editing
                aboutField.enabled = editing
                return view
            } else {
                let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Button Cell", forIndexPath:indexPath) as ButtonCollectionReusableView
                view.addButton.addTarget(self, action: "insertNewImage:", forControlEvents: .TouchUpInside)
                view.deleteButton.addTarget(self, action: "deleteFace:", forControlEvents: .TouchUpInside)
                view.hidden = !editing
                footerView = view
                return view
            }
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if editing {
                // Show actions menu
                let alertController = UIAlertController(title: "Actions", message: nil, preferredStyle: .ActionSheet)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                func deleteHandler(action: UIAlertAction!) {
                    if let detail = detailItem {
                        if let setName = parentController.detailItem as? String {
                            let setFolder = docPath.stringByAppendingPathComponent(setName)
                            let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(faces[detail]["id"] as Int))
                            NSFileManager.defaultManager().removeItemAtPath(imageFolder.stringByAppendingPathComponent(imageList[indexPath.item]), error: nil)
                            // Delete the image
                        }
                    }
                    collectionView.reloadData()
                }
                alertController.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: deleteHandler))
                alertController.popoverPresentationController?.sourceView = collectionView.cellForItemAtIndexPath(indexPath)!
                presentViewController(alertController, animated: true, completion: {})
            }
    }
    
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
