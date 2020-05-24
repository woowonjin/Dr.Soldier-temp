//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    var user : User?
    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    
    @IBAction func NavBtnClicked(_ sender: UIButton) {
        let nextMenu = sender.currentTitle!
        
        if let nextView = self.storyboard?.instantiateViewController(withIdentifier: nextMenu){
        self.navigationController?.pushViewController(nextView, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //subNavigation.removeAllSegments();
        //for menu in menus{
        //    subNavigation.insertSegment(withTitle: menu, at: menus.count, animated: false)
//        }
//        subNavigation.selectedSegmentIndex = 1;
        
        //self.navigationItem.hidesBackButton = true;
        //self.navigationItem.leftBarButtonItem = nil;
        
        //for DB test - by JJ
        /*
        print("-----------------")
        print(DB.database)
        print(DB.query(statement: Quary.SelectStar(Tablename: "Todo"), ColumnNumber: 2))
        print("-----------------")
         */
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
        
    }
    

        //let fileManager = FileManager.init()
        //print(fileManager.currentDirectoryPath)
        //let path = Bundle.main.resourcePath!
        //print(path)
    


}

