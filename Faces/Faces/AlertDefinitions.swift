//
//  AlertDefinitions.swift
//  Face Cards
//
//  Created by Anthony Li on 11/15/14.
//  Copyright (c) 2014 anli5005. All rights reserved.
//

import UIKit

/*
    An error alert is comprised of the following:
    SomethingErrorCode: "Some Alert Message"
*/

let errorAlerts: [Int: String] = [
    NSFileWriteInvalidFileNameError: "The set name was invalid.",
    NSFileWriteFileExistsError: "A set with that name already exists.",
    NSFileWriteOutOfSpaceError: "There isn't enough storage to create that."
]