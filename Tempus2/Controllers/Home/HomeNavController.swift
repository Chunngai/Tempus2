//
//  HomeNavController.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
    }
    
    private func updateViews() {
        view.backgroundColor = .white
    }
}
