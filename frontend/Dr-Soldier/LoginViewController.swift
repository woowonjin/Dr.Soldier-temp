//
//  LoginViewController.swift
//  Dr-Soldier
//
//  Created by 우원진 on 2020/05/07.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import KakaoOpenSDK
import Alamofire

class LoginViewController: UIViewController {

    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
    
       }
    
    let Url = "http://127.0.0.1:8000/users/kakaologin/"

    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    func post(email:String, nickname:String){
        
        //let user = User(email: email, nickname: nickname)
        let user_info : Parameters = [
            "email" : email,
            "nickname" : nickname
        ]
        

        
        let info = Url + "?email=\(email)&nickname=\(nickname)"
        
        AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "", method: .post, parameters: user_info, headers: header).responseJSON { response in
                
        }
    }
    //Info
    @IBAction func kakaoLoginOnClick(_ sender: Any) {
        guard let session = KOSession.shared() else{
            return
        }
        if session.isOpen(){
            session.close()
        }
        
        session.open(completionHandler: {(error) in
            if error == nil {
                print("no Error")
                
                if session.isOpen(){
                    KOSessionTask.userMeTask(completion: { (error, user) in
                        if error != nil{
                            return
                        }
                        guard let user = user,
                            let email = user.account?.email,
                            let nickName = user.nickname else { return }
                        let dict = ["email":email, "nickName":nickName]
                        let userInfo = UserDefaults.standard
                        userInfo.set(dict, forKey: "user")
                        self.post(email:email, nickname:nickName)
//                      let mainVC = MainViewController()
//                      mainVC.emailLabel.text = email
//                      mainVC.nicnameLabel.text = nickname
                        guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
                                   return
                        }
                        
                        //화면 전환 애니메이션을 설정합니다.
                        
                        main.modalPresentationStyle = .fullScreen
                        main.modalTransitionStyle = UIModalTransitionStyle.coverVertical

                        //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
                        self.present(main, animated: true)
                      
                    })
                    
                }
                else {
                    print("Fail")
                }
            }
            else{
                print("Error login \(String(describing: error))")
            }
        })
    }
}




