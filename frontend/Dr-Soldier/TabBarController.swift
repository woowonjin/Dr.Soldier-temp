//
//  TabBarController.swift
//  Dr-Soldier
//
//  Created by 우원진 on 2020/06/03.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire
class TabBarController: UITabBarController {

    @IBOutlet weak var myTabBar: UITabBar!
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var userEmail : String? // UserDefault -> Sqlite
    
    override func viewDidAppear(_ animated: Bool) {
            var fillDefaultColorsDictionary : [String:Int] = [:]
            let fillDefaultColorsArray = DB.query(statement: Query.SelectStar(Tablename: "Calendar"), ColumnNumber: 2)
            let _ = fillDefaultColorsArray.map({ each in
                fillDefaultColorsDictionary.updateValue(Int(each[1])! , forKey: each[0])
            })
            for date in fillDefaultColorsArray{
               AF.request("http://127.0.0.1:8000/create-vacation/?user=\(self.userEmail!)&date=\(date[0])&type=\(date[1])").responseJSON { response in
               }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        self.userEmail = result[0][0]
//        var fillDefaultColorsDictionary : [String:Int] = [:]
        AF.request("http://127.0.0.1:8000/delete-vacations/?user=\(userEmail!)").responseJSON { response in
        }
        usleep(500000)
//        let fillDefaultColorsArray = DB.query(statement: Query.SelectStar(Tablename: "Calendar"), ColumnNumber: 2)
//        let _ = fillDefaultColorsArray.map({ each in
//            fillDefaultColorsDictionary.updateValue(Int(each[1])! , forKey: each[0])
//        })
//        for date in fillDefaultColorsArray{
//
    }


}
