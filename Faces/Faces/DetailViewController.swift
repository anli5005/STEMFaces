//
//  DetailViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/19/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

var faces = [[String: AnyObject]]()
var nameOfSet: String?

enum SetLoadError {
    case None, FileLoading(NSError), SetJSON(NSError)
}

@objc protocol DetailControllerDelegate: NSObjectProtocol {
    optional func didRenameSetTo(newName: String, previousName: String)
}

class DetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FaceCardControllerDelegate {
    
    weak var delegate: DetailControllerDelegate?
    
    private var setLoaded = false
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            nameOfSet = detailItem as? String
            self.configureView()
        }
    }
    
    var error = SetLoadError.None
    
    var creatingNewFace = false
    
    private var _saveTimestamp: NSDate? = nil
    var saveTimestamp: NSDate? {
        return _saveTimestamp
    }
    
    func configureView() {
        if !setLoaded {
            faces = []
        }
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
            
            navigationItem.rightBarButtonItem = (nameOfSet == nil) ? nil : UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject")
            
            navigationItem.title = detail
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renameSet() {
        if nameOfSet != nil {
            let promptControl = UIAlertController(title: "Rename Set", message: nil, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            promptControl.addAction(cancelAction)
            promptControl.addAction(UIAlertAction(title: "Rename", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) in
                if let name = (promptControl.textFields![0] as UITextField).text {
                    if let setName = nameOfSet {
                        var error: NSError?
                        let filePath = docPath.stringByAppendingPathComponent(setName)
                        NSFileManager.defaultManager().moveItemAtPath(filePath, toPath: docPath.stringByAppendingPathComponent(name), error: &error)
                        if let theError = error {
                            let errorView = UIAlertController(title: "Oops!", message: (errorAlerts[theError.code] ?? "There was a problem. (Error code \(theError.code))"), preferredStyle: .Alert)
                            errorView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                            self.presentViewController(errorView, animated: true, completion: nil)
                        } else {
                            self.delegate?.didRenameSetTo?(name, previousName: setName)
                            self.detailItem = name
                        }
                    }
                }
            }))
            promptControl.addTextFieldWithConfigurationHandler({ (textField) in
                
            })
            presentViewController(promptControl, animated: true, completion: {})
        }
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
            // Perform segue
            var indexPath: NSIndexPath?
            for (aKey, aFace) in enumerate(faces) {
                if aFace["id"] as Int == face["id"] as Int {
                    indexPath = NSIndexPath(forItem: aKey, inSection: 0)
                }
            }
            if indexPath == nil {
                indexPath = NSIndexPath(forItem: 0, inSection: 0)
            }
            creatingNewFace = true
            performSegueWithIdentifier("showCard", sender: indexPath!)
            saveSet()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveSet()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier ?? "") == "showCard" {
            let dest = (segue.destinationViewController as UINavigationController).topViewController as FaceCardViewController
            dest.parentController = self
            dest.delegate = self
            dest.detailItem = (sender as NSIndexPath).item
            dest.setEditing(creatingNewFace, animated: true)
            creatingNewFace = false
        }
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        super.dismissViewControllerAnimated(flag, completion: completion)
        collectionView.reloadData()
    }
    
    func saveSet() -> NSError? {
        if let detail = detailItem as? String {
            var error: NSError?
            var data = NSJSONSerialization.dataWithJSONObject(faces, options: .PrettyPrinted, error: &error)
            if let e = error {
                println("Error making data: \(e.localizedDescription)")
            } else {
                _saveTimestamp = NSDate()
                collectionView.reloadData()
            }
            data?.writeToFile(docPath.stringByAppendingPathComponent(detail).stringByAppendingPathComponent("Data.json"), atomically: true)
            return error
        } else {
            return nil
        }
    }
    
    // MARK: Collection View Controller
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if nameOfSet == nil {
            return 0
        } else {
            if section == 0 {
                return activities.count
            } else {
                return faces.count
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var aCell: UICollectionViewCell
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Activity", forIndexPath: indexPath) as ActivityCollectionViewCell
            let activity = activities[indexPath.item]
            cell.nameLabel.text = activity["Name"]
            if faces.isEmpty {
                cell.detailLabel.text = "Requires 1 face"
            } else {
                cell.detailLabel.text = activity["Detail"]
            }
            aCell = cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Face Card", forIndexPath: indexPath) as FaceCardCollectionViewCell
            
            // Configure the cell with the face details.
            let face = faces[indexPath.item]
            cell.label?.text = (face["name"] as String)
            
            // Reset the image
            cell.image?.image = nil
            
            // Setup the image
            if let detail = detailItem as? String {
                let setFolder = docPath.stringByAppendingPathComponent(detail)
                let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(face["id"] as Int))
                let fileManager = NSFileManager.defaultManager()
                if fileManager.fileExistsAtPath(imageFolder) {
                    var items = [String]()
                    for item in (fileManager.contentsOfDirectoryAtPath(imageFolder, error: nil) as [String]) {
                        if !item.hasPrefix(".") && item.stringByDeletingPathExtension.toInt() != nil {
                            items.append(item)
                        }
                    }
                    if !items.isEmpty {
                        let imageList = sorted(items) { (in1: String, in2: String) in
                            return in1.stringByDeletingPathExtension.toInt()! < in2.stringByDeletingPathExtension.toInt()!
                        }
                        let imagePath = imageFolder.stringByAppendingPathComponent(imageList[0])
                        cell.image?.image = UIImage(contentsOfFile: imagePath)
                    }
                }
            }
            aCell = cell
        }
        return aCell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return !faces.isEmpty
        } else {
            return true
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier(activities[indexPath.item]["Segue-ID"], sender: indexPath)
        } else {
            // Perform the segue
            performSegueWithIdentifier("showCard", sender: indexPath)
        }
    }
    
    override func collectionView(collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Set Info", forIndexPath: indexPath) as SetDetailReusableView
            cell.nameLabel.text = nameOfSet ?? ""
            if let timestamp = saveTimestamp {
                let format = NSDateFormatter()
                format.dateStyle = .NoStyle
                format.timeStyle = .ShortStyle
                format.timeZone = NSTimeZone.defaultTimeZone()
                cell.saveLabel.text = "Last saved \(format.stringFromDate(timestamp))"
            } else {
                cell.saveLabel.text = ""
            }
            cell.renameButton.addTarget(self, action: "renameSet", forControlEvents: .TouchUpInside)
            return cell
    }
    
    // MARK: Collection View Flow Layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: 158, height: 87)
        } else {
            return CGSize(width: 130, height: 147)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
            if (section == 0) && (nameOfSet != nil) {
                return CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 82)
            } else {
                return CGSize(width: 0, height: 0)
            }
    }
    
    // MARK: Face Card Controller Delegate
    
    func shouldDismissController(controller: FaceCardViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
}

