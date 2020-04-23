//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.leftBarButtonItem = nil;
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
    }


}

