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
import FirebaseAuth
import CryptoKit

class LoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    
    fileprivate var currentNonce: String?
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        // Create an account in your system.
        
            // Save authorised user ID for future reference
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            let user = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let username = userLastName! + userFirstName!
//            let _ = self.DB.insert(statement: "DROP TABLE User;")
//            let _ = self.DB.CreateEveryTable()
//            let _ = self.DB.insert(statement: self.Query.insert(Tablename: "User", Values: "'\(email)', '\(username)','','','','' "))
//            post(email: email, nickname: username, method: "apple")
//            guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
//                return
//            }
            UserDefaults.standard.set(username, forKey: "username")
            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            
            Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
                // Do something after Firebase sign in completed
                guard let main = self?.storyboard?.instantiateViewController(withIdentifier: "Main") else{
                            return
                        }
                
                            //화면 전환 애니메이션을 설정합니다.
                
                            main.modalPresentationStyle = .fullScreen
                            main.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                
                            //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
                            self?.present(main, animated: true)
            }
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
//        let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//          print ("Error signing out: %@", signOutError)
//        }
        Auth.auth().addStateDidChangeListener({(user, error) in
            if Auth.auth().currentUser != nil{
                guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
                    return
                }
                //화면 전환 애니메이션을 설정합니다.
                main.modalPresentationStyle = .fullScreen
                main.modalTransitionStyle = UIModalTransitionStyle.coverVertical

                //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
                self.present(main, animated: true)
            }
            else{
                self.setupProviderLoginView()
            }
        })
    }
    
    
    
//    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
//        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
//        print(result)
//        if result.count != 0 {
//        guard let main = self.storyboard?.instantiateViewController(withIdentifier: "Main") else{
//                return
//            }
//            //화면 전환 애니메이션을 설정합니다.
//            main.modalPresentationStyle = .fullScreen
//            main.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//            //인자값으로 다음 뷰 컨트롤러를 넣고 present 메소드를 호출합니다.
//            self.present(main, animated: true)
//        }
 
//    }
    
    let Url = "http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/users/login/"

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

        // Generate nonce for validation after authentication successful
        self.currentNonce = randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = sha256(currentNonce!)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

//    func post(email:String, nickname:String, method:String){
//
//        //let user = User(email: email, nickname: nickname)
//        let user_info : Parameters = [
//            "email" : email,
//            "nickname" : nickname,
//            "method" : method
//        ]
//
//
//
//        let info = Url + "?email=\(email)&nickname=\(nickname)&method=\(method)"
//
//        AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "", method: .post, parameters: user_info, headers: header).responseJSON { response in
//
//        }
//    }
//    Info
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




