//
//  NotificationViewController.swift
//  Dr-Soldier
//
//  Created by 우원진 on 2020/06/01.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire

class NotificationViewController: UITableViewController{
    
    @IBOutlet var NotiTable: UITableView!
    
    let refreshNoti = UIRefreshControl()
    var notis : Array<Notification> = []
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var userEmail : String? // UserDefault -> Sqlite
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        NotiTable.refreshControl = refreshNoti
        self.refreshNoti.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.refreshNoti.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.userEmail = result[0][0]
        getNotis()
    }
    
    @objc func refresh(){
        notis.removeAll()
        getNotis()
        NotiTable.reloadData()
        self.refreshNoti.endRefreshing()
    }
    
    func getNotis(){
        AF.request("http://127.0.0.1:8000/get-notifications/?user=\(userEmail!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let responseList = value as! Array<AnyObject>
                
                let dateFormatter = DateFormatter()
                let now = Date()
                dateFormatter.dateFormat="yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                
                for (index, element) in responseList.enumerated(){
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
            
            case .failure(let error):
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
        cell.titleLabel.text = noti.type
        if noti.type == "좋아요"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물을 좋아합니다."
        }
        else if noti.type == "좋아요취소"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물 좋아요를 취소했습니다."
        }
        else if noti.type == "싫어요"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물을 싫어합니다."
        }
        else if noti.type == "싫어요취소"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물 싫어요를 취소했습니다."
        }
        else if noti.type == "댓글"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 게시물에 댓글을 달았습니다."
        }
        else if noti.type == "댓글좋아요"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글을 좋아합니다."
        }
        else if noti.type == "댓글좋아요취소"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글 좋아요를 취소했습니다."
        }
        else if noti.type == "댓글싫어요"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글을 싫어합니다."
        }
        else if noti.type == "댓글싫어요취소"{
            cell.descriptionLabel.text = "\(noti.user_name)님이 회원님의 댓글 싫어요를 취소했습니다."
        }
        cell.createdLabel.text = noti.created
        if(noti.is_read == false){
            cell.backgroundColor = UIColor(red:205/255, green: 255/255, blue: 0, alpha: 1)
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
        self.navigationController?.pushViewController(nextView, animated: true)
        if(noti.is_read == false){
            AF.request("http://127.0.0.1:8000/read_notification/?noti_pk=\(noti.pk)").responseJSON { response in
            }
        }
        self.refresh()
    }

    
}
