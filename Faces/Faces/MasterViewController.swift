//
//  MasterViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/19/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

/** Gets the folder path where documents are stored. */
let docPath: () -> String = {
    let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last! as NSURL
    return url.absoluteString!.stringByReplacingOccurrencesOfString("file://", withString: "")
}

/** The set selection, creation, and deletion screen. */
class MasterViewController: UITableViewController, DetailControllerDelegate {
    
    var detailViewController: DetailViewController? = nil
    /** A list of sets currently shown on the table view. */
    var objects = [String]()
    
    private let options = ["About", "Rate", "Support"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var error: NSError?
        let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(docPath(), error: &error) as [String]
        for file in fileList {
            if !file.hasPrefix(".") {
                objects.append(file)
            }
        }
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** Creates a new set. */
    func insertNewObject(sender: AnyObject) {
        let promptControl = UIAlertController(title: "Set Name", message: "In Face Cards, a set is a group of faces.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        promptControl.addAction(cancelAction)
        promptControl.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) in
            if let name = (promptControl.textFields![0] as UITextField).text {
                var error: NSError?
                let filePath = docPath().stringByAppendingPathComponent(name)
                NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil, error: &error)
                if let theError = error {
                    let errorView = UIAlertController(title: "Oops!", message: (errorAlerts[theError.code] ?? "There was a problem. (Error code \(theError.code))"), preferredStyle: .Alert)
                    errorView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(errorView, animated: true, completion: nil)
                } else {
                    self.objects.insert(name, atIndex: 0)
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }))
        promptControl.addTextFieldWithConfigurationHandler({ (textField) in
            
        })
        presentViewController(promptControl, animated: true, completion: {})
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                if indexPath.section == 1 {
                    
                } else {
                    let object = objects[indexPath.row] as String
                    let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                    controller.detailItem = object
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                    controller.delegate = self
                }
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var error: NSError?
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? options.count : objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            let object = options[indexPath.row]
            cell.textLabel?.text = object.lastPathComponent
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            
            let object = objects[indexPath.row] as String
            cell.textLabel?.text = object.lastPathComponent
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var error: NSError?
            NSFileManager.defaultManager().removeItemAtPath(docPath().stringByAppendingPathComponent(objects[indexPath.row]), error: &error)
            if error == nil {
                objects.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } else {
                let alert = UIAlertController(title: "Oops", message: "There was an error deleting the set. (\(error!.localizedDescription))", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        } else if editingStyle == .Insert {
            insertNewObject(self)
        }
    }
    
    // MARK: Detail Controller Delegate
    func didRenameSetTo(newName: String, previousName: String) {
        tableView.reloadData()
        var index: Int?
        for (anIndex, object) in enumerate(objects) {
            if object == previousName {
                index = anIndex
                break
            }
        }
        if let tIndex = index {
            objects[tIndex] = newName
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: tIndex, inSection: 0)], withRowAnimation: .Fade)
        }
    }
    
    
}

