//
//  TabBarController.swift
//  Dr-Soldier
//
//  Created by 우원진 on 2020/06/03.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class TabBarController: UITabBarController {

    @IBOutlet weak var myTabBar: UITabBar!
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var userEmail : String? // UserDefault -> Sqlite

    let Url = "http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/users/login/"
    
    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
//    override func viewDidAppear(_ animated: Bool) {
//            var fillDefaultColorsDictionary : [String:Int] = [:]
//            let fillDefaultColorsArray = DB.query(statement: Query.SelectStar(Tablename: "Calendar"), ColumnNumber: 2)
//            let _ = fillDefaultColorsArray.map({ each in
//                fillDefaultColorsDictionary.updateValue(Int(each[1])! , forKey: each[0])
//            })
//            for date in fillDefaultColorsArray{
//               AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/create-vacation/?user=\(self.userEmail!)&date=\(date[0])&type=\(date[1])").responseJSON { response in
//               }
//            }
//        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let user = Auth.auth().currentUser
//        //        var fillDefaultColorsDictionary : [String:Int] = [:]
//        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
////        let appleID = UserDefaults.standard.value(forKey: "appleAuthorizedUserIdKey")
//        if UserDefaults.standard.value(forKey: "username") != nil{
//        let username = UserDefaults.standard.value(forKey: "username") as! String
////        if username == nil{
////            post(email: (user?.email!)!, nickname: (user?.email!)!, method: "apple")
////            if result.count != 0 {
////                let _ = self.DB.insert(statement: "DROP TABLE User;")
////                let _ = self.DB.CreateEveryTable()
////                let _ = self.DB.insert(statement: self.Query.insert(Tablename: "User", Values: "'\((user?.email!)!)', '\((user?.email!)!)','','','','' "))
////            }
////        }
////        else{
////            post(email: (user?.email!)!, nickname: username, method: "apple")
////            if result.count != 0 {
////                let _ = self.DB.insert(statement: "DROP TABLE User;")
////                let _ = self.DB.CreateEveryTable()
////                let _ = self.DB.insert(statement: self.Query.insert(Tablename: "User", Values: "'\((user?.email!)!)', '\(username!)','','','','' "))
////            }
////        }
////
//            self.userEmail = (user?.email!)!
//            post(email: (user?.email!)!, nickname: username, method: "apple")
//            if result.count == 0 {
//                let _ = self.DB.insert(statement: "DROP TABLE User;")
//                let _ = self.DB.CreateEveryTable()
//                let _ = self.DB.insert(statement: self.Query.insert(Tablename: "User", Values: "'\((user?.email!)!)', '\(username)','','','','' "))
//            }
//        }
////        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/delete-vacations/?user=\((user?.email!)!)").responseJSON { response in
////        }
    }
    
    
    
    func post(email:String, nickname:String, method:String){

        //let user = User(email: email, nickname: nickname)
        let user_info : Parameters = [
            "email" : email,
            "nickname" : nickname,
            "method" : method
        ]



        let info = Url + "?email=\(email)&nickname=\(nickname)&method=\(method)"

        AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "", method: .post, parameters: user_info, headers: header).responseJSON { response in

        }
    }

}
