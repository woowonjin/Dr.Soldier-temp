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
import AuthenticationServices

class LoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        // Create an account in your system.
            let user = appleIDCredential.user
        let userFirstName = appleIDCredential.fullName?.givenName
        let userLastName = appleIDCredential.fullName?.familyName
        let userEmail = appleIDCredential.email
        let username = userLastName! + userFirstName!
            let email : String
            if(userEmail == nil){
                email = user + ".icloud.com"
            }
            else{
                email = userEmail!
            }
            
            self.DB.insert(statement: "DROP TABLE User;")
                                self.DB.CreateEveryTable()
                                self.DB.insert(statement: self.Query.insert(Tablename: "User", Values: "'\(email)', '\(username)','','','','' "))
        post(email: email, nickname: username, method: "apple")
        guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
            return
        }
                           
            //화면 전환 애니메이션을 설정합니다.
                           
            main.modalPresentationStyle = .fullScreen
            main.modalTransitionStyle = UIModalTransitionStyle.coverVertical

            //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
            self.present(main, animated: true)
                         
        }
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }

//    private let kakaoLoginButton: KOLoginButton = {
//        let button = KOLoginButton()
//        button.addTarget(self, action: #selector(kakaoLogin), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.cornerRadius = 20.0
//
//      return button
//    }()
    
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        print(result)
        if result.count != 0 {
        guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
                return
            }
            //화면 전환 애니메이션을 설정합니다.
            main.modalPresentationStyle = .fullScreen
            main.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
            self.present(main, animated: true)
        }
 
    }
    
    let Url = "http://127.0.0.1:8000/users/login/"

    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
            authorizationButton.addTarget(self, action: #selector(appleLogin), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
//        self.loginProviderStackView.addArrangedSubview(kakaoLoginButton)
      }

    @objc func appleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
              
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
    //Info
//    @objc func kakaoLogin() {
//        guard let session = KOSession.shared() else{
//            return
//        }
//        if session.isOpen(){
//            session.close()
//        }
//        session.open(completionHandler: {(error) in
//        if error == nil {
//            print("no Error")
//            if session.isOpen(){
//                KOSessionTask.userMeTask(completion: { (error, user) in
//                if error != nil{
//                    return
//                }
//                    guard let user = user,
//                    let email = user.account?.email,
//                    let nickName = user.nickname else { return }
//
//
//
//                    //가장 처음으로 앱을 켰을때
//                    self.DB.insert(statement: "DROP TABLE User;")
//                    self.DB.CreateEveryTable()
//                    self.DB.insert(statement: self.Query.insert(Tablename: "User", Values: "'\(email)', '\(nickName)','','','','' "))
//
//
//                    self.post(email:email, nickname:nickName, method:"kakao")
//                    guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
//                               return
//                    }
//
//                    //화면 전환 애니메이션을 설정합니다.
//
//                    main.modalPresentationStyle = .fullScreen
//                    main.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//
//                    //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
//                    self.present(main, animated: true)
//
//                })
//
//                }
//                else {
//                    print("Fail")
//                }
//            }
//            else{
//                print("Error login \(String(describing: error))")
//            }
//        })
//    }
}




