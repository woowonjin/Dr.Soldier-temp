//
//  NotificationViewController.swift
//  Dr-Soldier
//
//  Created by 우원진 on 2020/06/01.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth

class NotificationViewController: UITableViewController{
    
    @IBOutlet var NotiTable: UITableView!
    let uid = Auth.auth().currentUser?.uid
    let refreshNoti = UIRefreshControl()
    var notis : Array<Notification> = []
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var userEmail : String? // UserDefault -> Sqlite
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navview = MakeViewWithNavigationBar.init(InputString: " Feeds",InputImage: UIImage(named: "chats")!)
        self.navigationItem.titleView = navview.navView
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        NotiTable.refreshControl = refreshNoti
        self.refreshNoti.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.refreshNoti.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.userEmail = result[0][0]
//        getNotis()
    }
    
    @objc func refresh(){
        notis.removeAll()
        getNotis()
        NotiTable.reloadData()
        self.refreshNoti.endRefreshing()
    }
    
    func getNotis(){
        
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/get-notifications/?user=\(self.uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let responseList = value as! Array<AnyObject>
                
                let dateFormatter = DateFormatter()
                let now = Date()
                dateFormatter.dateFormat="yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                
                for (index, _) in responseList.enumerated(){
                    //let obj = element["fields"] as! AnyObject
                    let post_pk = responseList[index]["post_pk"] as! Int
                    let is_read = responseList[index]["is_read"] as! Bool
                    let pk = responseList[index]["pk"] as! Int
                    let post_title = responseList[index]["post_title"] as! String
                    let description = responseList[index]["post_description"] as! String
                    let likes = responseList[index]["post_likes"] as! Int
                    let dislikes = responseList[index]["post_dislikes"] as! Int
                    let comments = responseList[index]["post_comments"] as! Int
                    let type = responseList[index]["type"] as! String
                    let user_name = responseList[index]["user_name"] as! String
                    let created = responseList[index]["created"] as! String
                    let end = created.index(created.endIndex, offsetBy: -7)
                    let tmpstr = String(created[...end]) // Date 로 바꾸기 위해 잘라준다.
                    //print(host)
                    let st = tmpstr.components(separatedBy: ".")
                    let date = dateFormatter.date(from: st[0])
                    let intervalSecond = now.timeIntervalSince(date!)
                    
                    let createdStr : String
                    
                    switch intervalSecond {
                    case 0...3600:
                        let m : Int = Int(intervalSecond / 60)
                        if(m == 0){ createdStr = "방금" }
                        else{ createdStr = "\(m)분 전" }
                    case 3601...3600*24:
                        let h : Int = Int(intervalSecond / 3600)
                        createdStr = "\(h)시간 전"
                    case 3600*24...3600*24*365:
                        let d : Int = Int(intervalSecond / (3600*24))
                        createdStr = "\(d)일 전"
                    default:
                        let d : Int = Int(intervalSecond / (3600*24*365))
                        createdStr = "\(d)년 전"
                    }
                    
                    self.notis.insert(Notification(pk : pk, post_title : post_title, is_read : is_read, type : type, user_name : user_name, post_pk : post_pk, created : createdStr, likes: likes, dislikes: dislikes, comments: comments, description: description), at: index)
                    DispatchQueue.main.async {
                        self.NotiTable.reloadData()
                    }
                }
            
            case .failure( _):
                print("getting Notifications failed")
            }
        }
        var num = 0;
        for noti in notis{
            if(noti.is_read == false){
                num += 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notis.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NotiTable.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let noti = notis[indexPath.row]
        if noti.type == "좋아요"{
            cell.titleLabel.text = "좋아요"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물을 좋아합니다."
            cell.notiImage.image = UIImage(systemName: "heart.fill")
            cell.notiImage.tintColor = UIColor(red: 255, green: 153, blue: 204)
        }
        else if noti.type == "좋아요취소"{
            cell.titleLabel.text = "좋아요 취소"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물 좋아요를 취소했습니다."
            cell.notiImage.image = UIImage(systemName: "heart.fill")
            cell.notiImage.tintColor = UIColor(red: 255, green: 153, blue: 204)
        }
        else if noti.type == "싫어요"{
            cell.titleLabel.text = "싫어요"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물을 싫어합니다."
            cell.notiImage.image = UIImage(systemName: "hand.thumbsdown.fill")
            cell.notiImage.tintColor = UIColor(red: 153, green: 204, blue: 255)
        }
        else if noti.type == "싫어요취소"{
            cell.titleLabel.text = "싫어요 취소"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물 싫어요를 취소했습니다."
            cell.notiImage.image = UIImage(systemName: "hand.thumbsdown.fill")
            cell.notiImage.tintColor = UIColor(red: 153, green: 204, blue: 255)
        }
        else if noti.type == "댓글"{
            cell.titleLabel.text = "댓글"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물에 댓글을 달았습니다."
            cell.notiImage.image = UIImage(systemName: "message.fill")
            cell.notiImage.tintColor = UIColor(red: 90, green: 193, blue: 142)
        }
        else if noti.type == "댓글좋아요"{
            cell.titleLabel.text = "댓글좋아요"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글을 좋아합니다."
            cell.notiImage.image = UIImage(systemName: "heart.fill")
            cell.notiImage.tintColor = UIColor(red: 255, green: 153, blue: 204)
        }
        else if noti.type == "댓글좋아요취소"{
            cell.titleLabel.text = "댓글좋아요 취소"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글 좋아요를 취소했습니다."
            cell.notiImage.image = UIImage(systemName: "heart.fill")
            cell.notiImage.tintColor = UIColor(red: 255, green: 153, blue: 204)
        }
        else if noti.type == "댓글싫어요"{
            cell.titleLabel.text = "댓글싫어요"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글을 싫어합니다."
            cell.notiImage.image = UIImage(systemName: "hand.thumbsdown.fill")
            cell.notiImage.tintColor = UIColor(red: 153, green: 204, blue: 255)
        }
        else if noti.type == "댓글싫어요취소"{
            cell.titleLabel.text = "댓글싫어요 취소"
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글 싫어요를 취소했습니다."
            cell.notiImage.image = UIImage(systemName: "hand.thumbsdown.fill")
            cell.notiImage.tintColor = UIColor(red: 153, green: 204, blue: 255)
        }
        let AttributedString = MakeAttributedString.init(InputString: cell.descriptionLabel.text!)
        AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(noti.user_name)")
        AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 20), WhichPart: "\(noti.user_name)")
        cell.descriptionLabel.attributedText = AttributedString.AttributedString
        
        cell.createdLabel.text = noti.created
        if(noti.is_read == false){
            cell.backgroundColor = UIColor(red:250/255, green: 235/255, blue: 215/255, alpha: 0.5)
        }
        else{
            cell.backgroundColor = .white
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentDetailViewController") as! DocumentDetailViewController
        let noti = notis[indexPath.row]
        nextView.post_pk = noti.post_pk
        nextView.likes = noti.likes
        nextView.dislikes = noti.dislikes
        nextView.comments_number = noti.comments
        nextView.titleString = noti.post_title
        nextView.descriptionString = noti.description
        notis[indexPath.row].is_read = true
        self.navigationController?.pushViewController(nextView, animated: true)
        let cell = NotiTable.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        if(noti.is_read == false){
            cell.backgroundColor = .white
            AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/read_notification/?noti_pk=\(noti.pk)").responseJSON { response in
            }
        }
    }

    
}
