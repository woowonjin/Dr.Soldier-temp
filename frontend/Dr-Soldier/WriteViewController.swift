//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire

class WriteViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var userEmail : String? // UserDefault -> Sqlite
    
    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    func placeholderSetting() {
            contentTextView.delegate = self // txtvReview가 유저가 선언한 outlet
            contentTextView.text = "내용을 입력하세요."
            contentTextView.textColor = UIColor.lightGray
            
        }
        
        
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용을 입력하세요."
            textView.textColor = UIColor.lightGray
        }
    }

    
    @objc func writeButtonClicked(){
        print("write button Clicked!")
        //let user = UserDefaults.standard.dictionary(forKey: "user")

        let params : Parameters = ["title":titleTextField.text!, "content":contentTextView.text!, "user":self.userEmail!]
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
//        nextView.refresh()
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
        placeholderSetting()
        self.contentTextView.layer.borderWidth = 0.8
        self.contentTextView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        self.contentTextView.layer.cornerRadius = 5
        self.navigationItem.leftBarButtonItem?.tintColor = .white
        self.navigationItem.backBarButtonItem?.tintColor = .white
        
        let writeButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(writeButtonClicked))
        writeButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = writeButton
        
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        self.userEmail = result[0][0]
    }


}

