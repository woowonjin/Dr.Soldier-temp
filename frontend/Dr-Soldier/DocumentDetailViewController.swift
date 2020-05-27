//
//  DocumentDetailViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/05/01.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire

class DocumentDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
     private var refreshControl = UIRefreshControl()
    @IBOutlet weak var commentTextField: UITextField!
    //var user: User?

    var titleString : String = ""
    var descriptionString : String = ""
    var post_pk = -1
    var likes = 0;
    var dislikes = 0;
    var comments_number = 0;
    var isLike = false
    var comments : Array<Comment> = [
    ]
    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTable: UITableView!
    
    func getInfo(){
        AF.request("http://127.0.0.1:8000/post/info/?pk=\(self.post_pk)").responseJSON { response in
            switch response.result{
            case .success(let value):
                print("!!")
            case .failure(let error):
                print("maybe server down")
            }
        }
    }
    
    func getComments(){
        AF.request("http://127.0.0.1:8000/comments/?pk=\(self.post_pk)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let responseList = value as! Array<AnyObject>
                self.comments.insert(Comment(description: "댓글", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false, pk: -1), at: 0)
                for (index, element) in responseList.enumerated(){
                    let text = responseList[index]["text"] as! String
                    let writer = responseList[index]["host_name"] as! String
                    let likes = responseList[index]["likes_number"] as! Int
                    let disLikes = responseList[index]["dislikes_number"] as! Int
                    let pk = responseList[index]["pk"] as! Int
                    self.comments.insert(Comment(description: text, created: "방금", writer: writer, thumbsUp: likes, thumbsDown: disLikes, isDeleted: false, pk: pk), at: index+1)
                }
//                self.likeRequest()
                print("comments:", self.comments)
                DispatchQueue.main.async {
                    self.commentTable.reloadData()
                }
            case .failure(let error):
                print("maybe server down")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = commentTable.dequeueReusableCell(withIdentifier: "DocumentDetailCell", for: indexPath) as! DocumentDetailCell
            cell.titleLabel.text = titleString
            cell.descriptionLabel.text = descriptionString
            print("table likes", likes)
            cell.LikesButton.titleLabel?.text = String(likes)
            print("cell likes", cell.LikesButton.titleLabel?.text)
            cell.DislikesButton.titleLabel?.text = String(dislikes)
            cell.CommentsButton.titleLabel?.text = String(comments_number)
            if self.isLike{
                let img = UIImage(named: "heart.fill")
                cell.likeBtn.setBackgroundImage(img, for: .normal)
            }
            else{
                let img = UIImage(named: "heart")
                cell.likeBtn.setBackgroundImage(img, for: .normal)
            }
            print("cell")
            return cell
        }else{
            let cell = commentTable.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row]
            cell.UserNameLabel.text = comment.writer
            cell.DescriptionLabel.text = comment.description
            cell.thumbsUpBtn.titleLabel?.text = String(comment.thumbsUp)
            cell.thumbsDownBtn.titleLabel?.text = String(comment.thumbsDown)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func likeRequest(){
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/alreadylikes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as! AnyObject
                self.isLike = rep["like"]! as! Bool
            case .failure(let value):
                print("like request Error")
            }
        }

    }

    
    
    @IBAction func likePost(_ sender: UIButton) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/likes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        if isLike{
            print("Cancel Like")
            isLike = false
        }
        else{
            print("I like this post")
            isLike = true
        }
        let time = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: time){
            self.refreshComment()
        }
        print("like btn clicked")
    }
    
    @IBAction func dislikePost(_ sender: Any) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/dislikes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        print("dislike btn clicked")
    }
    
//    @IBAction func dislikeComment(_ sender: Any) {
//    }
//    
//    @IBAction func likeComment(_ sender: Any) {
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTable.refreshControl = refreshControl
        self.refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refreshComment), for: .valueChanged)
        getComments()
        likeRequest()
        commentTable.delegate = self
        commentTable.dataSource = self
        commentTable.estimatedRowHeight = 100
        commentTable.rowHeight = UITableView.automaticDimension
        //refreshComment()
    }
    
    @objc func refreshComment(){
        comments.removeAll()
        getComments()
        commentTable.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        let params : Parameters = [ "content":commentTextField.text!]
        print(params)
        let url = "http://127.0.0.1:8000/comments/create/"
                
        let info = url + "?content=\(params["content"]!)&pk=\(self.post_pk)&user=\((user!["email"])! as! String)"
        AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "",
                    method: .post, parameters: params, headers: header).responseJSON { response in
        }
        let time = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: time){
            self.refreshComment()
        }
//        DispatchQueue.main.async {
//            self.commentTable.reloadData()
//        }
    }
    
}
