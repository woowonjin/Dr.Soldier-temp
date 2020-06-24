//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire

class WriteViewController: UIViewController {
    
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var userEmail : String? // UserDefault -> Sqlite
    
    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    @objc func writeButtonClicked(){
        print("write button Clicked!")
        //let user = UserDefaults.standard.dictionary(forKey: "user")

        let params : Parameters = ["title":titleTextField.text!, "content":contentTextField.text!, "user":self.userEmail!]
        let url = "http://127.0.0.1:8000/posts/create/"
        

//<<<<<<< HEAD
//        let info = url + "?title=\(params["title"]!)&content=\(params["content"]!)"
//        AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "",
//                   method: .post, parameters: params, headers: header).responseJSON { response in
//=======
        let info = url + "?title=\(params["title"]!)&content=\(params["content"]!)&user=\(params["user"]!)"
        AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "", method: .post, parameters: params, headers: header).responseJSON { response in
//>>>>>>> 6222f7cdb359bb1a2d20f6efa6f9979a98055b91
        }
        _ = self.storyboard?.instantiateViewController(withIdentifier: "Community") as! CommunityViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let navView = UIView()
        let label = UILabel()
        label.text = "글 쓰기"
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        label.textColor = UIColor.white
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        let image = UIImageView()
        image.image = UIImage(named: "doctor3.png")
        let imageAspect = image.image!.size.width/image.image!.size.height
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        
        navView.addSubview(label)
        navView.addSubview(image)
        self.navigationItem.titleView = navView
        
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        self.navigationItem.backBarButtonItem?.tintColor = .white
        
        let writeButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(writeButtonClicked))
        writeButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = writeButton
        
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        self.userEmail = result[0][0]
    }


}

