//
//  HomeTimetableProtocol.swift
//  Tempus2
//
//  Created by Sola on 2022/7/10.
//  Copyright © 2022 Sola. All rights reserved.
//

import Foundation
import UIKit

protocol HomeTimetableDelegate: UIViewController {
    
    func add(_ task: Task)
    func replace(_ oldTask: Task, with newTask: Task)
    func edit(_ task: Task)
    func remove(_ task: Task)
    
    func taskConflicted(with newTask: Task) -> Task?  // TODO: - check
    
    func display(_ task: Task)
}
