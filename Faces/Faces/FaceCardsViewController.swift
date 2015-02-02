//
//  FaceCardsViewController.swift
//  Face Cards
//
//  Created by Anthony Li on 1/22/15.
//  Copyright (c) 2015 anli5005. All rights reserved.
//

import UIKit

// MARK: - Page view controller for face cards
/** Page view controller for face cards */
class FaceCardsViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var parentController: DetailViewController!
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        self.recalculateScrollInsets()
    }
    
    func viewControllerForFaceCardAtIndex(index: Int) -> FaceCardViewController? {
        let v = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("card") as FaceCardViewController
        v.parentController = parentController
        v.delegate = parentController
        v.detailItem = index
        v.setEditing(self.editing, animated: true)
        return v
    }
    
    private func applyScrollInsetsTo(scrollView: UIScrollView?) {
        var navbarHeight = self.navigationController!.navigationBar.frame.size.height
        var sizeClass = self.traitCollection.verticalSizeClass == .Compact
        var extraHeight: CGFloat = sizeClass ? 3 : 20
        scrollView?.contentInset = UIEdgeInsetsMake(navbarHeight + extraHeight, 0, 0, 0)
    }
    
    private func recalculateScrollInsets() {
        for v in (self.viewControllers) as [UICollectionViewController!] {
            self.applyScrollInsetsTo(v.collectionView)
        }
    }

    override func viewDidLoad() {        
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = self.editButtonItem()
        self.dataSource = self
        self.delegate   = self
        self.view.backgroundColor = UIColor.whiteColor()
        
        applyScrollInsetsTo(self.viewControllers[0].collectionView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func showFaceCardAtIndex(index: Int) {
        self.setViewControllers([viewControllerForFaceCardAtIndex(index)!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let d = (viewController as FaceCardViewController).detailItem {
            let i = d + 1
            if i >= faces.count {
                return nil
            } else {
                let v = viewControllerForFaceCardAtIndex(i)
                self.applyScrollInsetsTo(v!.collectionView)
                return v
            }
        } else {
            return nil
        }
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let d = (viewController as FaceCardViewController).detailItem {
            let i = d - 1
            if i < 0 {
                return nil
            } else {
                let v = viewControllerForFaceCardAtIndex(i)
                self.applyScrollInsetsTo(v!.collectionView)
                return v
            }
        } else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return faces.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return (viewControllers[0] as FaceCardViewController).detailItem ?? 0
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        for v in self.viewControllers {
            (v as UIViewController).setEditing(editing, animated: animated)
        }
    }
}
