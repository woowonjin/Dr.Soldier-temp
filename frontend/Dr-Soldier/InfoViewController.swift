//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    
    @IBOutlet weak var subNavigation: UISegmentedControl!
    let menus = ["Finance", "Info", "Calendar"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        subNavigation.removeAllSegments();
        for menu in menus{
            subNavigation.insertSegment(withTitle: menu, at: menus.count, animated: false)
        }
        subNavigation.selectedSegmentIndex = 1;
        
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.leftBarButtonItem = nil;
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
        
    }
    
    @IBAction func _changeMenu(_ sender: Any) {
        print(DB.query(statement: Quary.SelectStar(Tablename: "Todo"), ColumnNumber: 2))
        //let fileManager = FileManager.init()
        //print(fileManager.currentDirectoryPath)
        //let path = Bundle.main.resourcePath!
        //print(path)
        
        
        let nextMenu = menus[subNavigation.selectedSegmentIndex];
        if let nextView = self.storyboard?.instantiateViewController(withIdentifier: nextMenu){
        self.navigationController?.pushViewController(nextView, animated: false)
        }
        
        
    }
    


}

