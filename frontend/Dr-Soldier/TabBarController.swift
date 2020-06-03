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
    override func viewDidLoad() {
        super.viewDidLoad()
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        self.userEmail = result[0][0]
        AF.request("http://127.0.0.1:8000/get-notifications-num/?user=\(userEmail!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                print(value)
                let rep = value as! AnyObject
                let number = rep["unread"] as! String
                for item in self.myTabBar.items!{
                    if(item.title == "Notification"){
                        item.badgeValue = number
                    }
                }
            case .failure(let error):
                print("Server Error")
            }
        }
    }


}
