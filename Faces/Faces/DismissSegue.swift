//
//  DismissSegue.swift
//  Faces
//
//  Created by Anthony Li on 11/1/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        (sourceViewController as UIViewController).presentingViewController!.dismissViewControllerAnimated(true, completion: {})
    }
}
