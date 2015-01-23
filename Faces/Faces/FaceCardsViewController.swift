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
    
    func viewControllerForFaceCardAtIndex(index: Int) -> FaceCardViewController? {
        let v = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("card") as FaceCardViewController
        v.parentController = parentController
        v.delegate = parentController
        v.detailItem = index
        v.setEditing(self.editing, animated: true)
        return v
    }
    
    private func applyScrollInsetsTo(scrollView: UIScrollView?) {
        let navbarHeight = self.navigationController!.navigationBar.frame.size.height
        scrollView?.contentInset = UIEdgeInsetsMake(navbarHeight + 20, 0, 0, 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = self.editButtonItem()
        self.dataSource = self
        self.delegate   = self
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
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        for v in self.viewControllers {
            (v as UIViewController).setEditing(editing, animated: animated)
        }
    }

}
