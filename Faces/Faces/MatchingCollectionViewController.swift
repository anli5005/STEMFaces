//
//  MatchingCollectionViewController.swift
//  Face Cards
//
//  Created by Anthony Li on 1/23/15.
//  Copyright (c) 2015 anli5005. All rights reserved.
//

import UIKit

class MatchingCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private typealias CellType = MatchingCollectionViewCell.MatchingCellType
    
    override func viewDidLoad() {
        self.collectionViewSize = self.view.frame.size
        
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.collectionView!.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateCellDescriptions() -> ([MatchingCollectionViewCell.MatchingCellType], [Int]) {
        var types: [CellType] = [CellType](count: numberOfFaces, repeatedValue: .Text) + [CellType](count: numberOfFaces, repeatedValue: .Image)
        var cells: [Int] = []
        for (k, _) in enumerate(faces) {
            cells.append(k)
        }
        func randomSort<T>(a: [T]) -> [T] {
            return sorted(sorted(a) { (x, y) in
                (rand() % 2) == 1
                }, { (x, y) in
                    (rand() % 2) == 1
            })
        }
        cells = [Int](cells[0..<(numberOfFaces)])
        let textCells = randomSort(cells)
        let imageCells = randomSort(cells)
        var textI = 0; var imageI = 0
        let theTypes = randomSort(types)
        var theCells = [Int]()
        for t in theTypes {
            if t == .Text {
                theCells.append(textCells[textI])
                textI++
            } else if t == .Image {
                theCells.append(imageCells[imageI])
                imageI++
            }
        }
        return (theTypes, theCells)
    }
    
    var numberOfFaces: Int = {
        return faces.count >= 4 ? 4 : faces.count
        }()
    
    var _cellDescriptions: ([MatchingCollectionViewCell.MatchingCellType], [Int])?
    var cellDescriptions: ([MatchingCollectionViewCell.MatchingCellType], [Int]) {
        if _cellDescriptions == nil {
            _cellDescriptions = self.generateCellDescriptions()
        }
        return _cellDescriptions!
    }
    
    var selectedCells: [Int] = {
        var a = [Int]()
        a.reserveCapacity(2)
        return a
        }()
    var disabledCells = [Int]()
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 * numberOfFaces
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellType = cellDescriptions.0[indexPath.item]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellType == .Image ? "ImageMatch" : "TextMatch", forIndexPath: indexPath) as MatchingCollectionViewCell
        
        // Configure the cell
        cell.personId = cellDescriptions.1[indexPath.item]
        cell.refreshFaceData()
        
        // Add an image if possible
        if cell.getCellType() == .Image {
            if let setName = nameOfSet {
                let setFolder = docPath().stringByAppendingPathComponent(setName)
                let imageFolder = setFolder.stringByAppendingPathComponent("Images").stringByAppendingPathComponent(String(faces[cell.personId!]["id"] as Int))
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
                let imageList = sorted(sorted(items, { (in1: String, in2: String) in
                    return (rand() % 2) == 1
                }), { (in1: String, in2: String) in
                    return (rand() % 2) == 1
                })
                if let imageFile = imageList.first {
                    cell.imageView!.image = UIImage(contentsOfFile: imageFolder.stringByAppendingPathComponent(imageFile))
                } else {
                    cell.imageView!.image = nil
                }
            }
        }
        
        // Add colors
        if (indexPath.item % 2) == Int(floor(Double(indexPath.item) / 2)) % 2 {
            cell.backgroundColor = UIColor(white: 1.00, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(white: 0.75, alpha: 1)
        }
        
        return cell
    }
    
    private var collectionViewSize = CGSize(width: 0, height: 0)
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.collectionViewSize.width / 2, height: self.collectionViewSize.height / 4)
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !contains(disabledCells, indexPath.item)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if selectedCells.count < 2 {
            let i = indexPath.item
            if selectedCells.first != i {
                selectedCells.append(i)
                let cell = self.collectionView!.cellForItemAtIndexPath(indexPath)! as MatchingCollectionViewCell
                cell.elementSelected = true
                if selectedCells.count > 1 {
                    // Evaluate the choices
                    let cView: UICollectionView = self.collectionView!
                    let cCell = cView.cellForItemAtIndexPath(NSIndexPath(forItem: selectedCells[0], inSection: 0))!
                    let otherCell = cCell as MatchingCollectionViewCell
                    cell.elementSelected = false
                    otherCell.elementSelected = false
                    // Check the indexes of the faces
                    cell.userCorrect = (cell.personId == otherCell.personId)
                    otherCell.userCorrect = (cell.personId == otherCell.personId)
                    if cell.userCorrect! == true {
                        disabledCells.extend(selectedCells)
                    } else {
                        // Schedule a timer to hide the choices
                        NSTimer.scheduledTimerWithTimeInterval(2, target: cell, selector: "hideUserScore:", userInfo: nil, repeats: false)
                        NSTimer.scheduledTimerWithTimeInterval(2, target: otherCell, selector: "hideUserScore:", userInfo: nil, repeats: false)
                    }
                    
                    selectedCells = []
                }
            } else {
                selectedCells.removeLast()
                let cell = self.collectionView!.cellForItemAtIndexPath(indexPath)! as MatchingCollectionViewCell
                cell.elementSelected = false
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionViewSize = size
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView?.reloadData()
    }
}
