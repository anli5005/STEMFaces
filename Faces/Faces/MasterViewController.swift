//
//  MasterViewController.swift
//  Faces
//
//  Created by Anthony Li on 10/19/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

let docPath: String = {
    let url = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last! as NSURL
    return url.absoluteString!.stringByReplacingOccurrencesOfString("file://", withString: "")
}()

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [String]()


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
        let fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(docPath, error: &error) as [String]
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

    func insertNewObject(sender: AnyObject) {
        let promptControl = UIAlertController(title: "Set Name", message: nil, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        promptControl.addAction(cancelAction)
        promptControl.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) in
            if let name = (promptControl.textFields![0] as UITextField).text {
                var error: NSError?
                let filePath = docPath.stringByAppendingPathComponent(name)
                NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil, error: &error)
                if error != nil {
                    let errorView = UIAlertView()
                    errorView.title = "Error"
                    errorView.message = error!.localizedDescription
                    errorView.addButtonWithTitle("OK")
                    errorView.cancelButtonIndex = 0
                    errorView.show()
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
                let object = objects[indexPath.row] as String
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var error: NSError?
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = objects[indexPath.row] as String
        cell.textLabel.text = object.lastPathComponent
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var error: NSError?
            NSFileManager.defaultManager().removeItemAtPath(docPath.stringByAppendingPathComponent(objects[indexPath.row]), error: &error)
            if error == nil {
                objects.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } else {
                let alert = UIAlertView()
                alert.title = "Error deleting set"
                alert.message = error!.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.cancelButtonIndex = 0
                alert.show()
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

