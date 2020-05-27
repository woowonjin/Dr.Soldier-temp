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
    let like = UIButton(type:.system)
    let dislike = UIButton(type:.system)
    
    var titleString : String = ""
    var descriptionString : String = ""
    var post_pk = -1
    var likes = 0;
    var dislikes = 0;
    var comments_number = 0;
    var isLike = false
    var isDislike = false
    var comments : Array<Comment> = [
    ]
    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTable: UITableView!
    
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
    
    func firstCell()->UIView{
        // 라이트 뷰 생성
        let rightView = UIView()
        let bounds: CGRect = UIScreen.main.bounds
        rightView.frame = CGRect(x: bounds.maxX-100, y: 0, width: 80, height: 40)
        // rItem이라는 UIBarButtonItem 객체 생성
//        let rItem = UIBarButtonItem(customView: rightView)
//        self.navigationItem.rightBarButtonItem = rItem
        // 글쓰기 버튼 생성
//        let like = UIButton(type:.system)
        like.frame = CGRect(x:10, y:8, width: 30, height: 30)
        if isLike{
            like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        else{
            like.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        like.tintColor = .red
        like.addTarget(self, action: #selector(likePost(_:)), for: .touchUpInside)
        // 라이트 뷰에 버튼 추가
        rightView.addSubview(like)
//        let dislike = UIButton(type:.system)
        dislike.frame = CGRect(x:50, y:8, width: 30, height: 30)
        if isDislike{
            dislike.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        else{
            dislike.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        }
        dislike.tintColor = .blue
        dislike.addTarget(self, action: #selector(dislikePost(_:)), for: .touchUpInside)
        // 라이트 뷰에 버튼 추가
        rightView.addSubview(dislike)
        return rightView
    }
    
//    func restCell(cell: CommentCell)->UIView{
//            // 라이트 뷰 생성
//            let rightView = UIView()
//            let bounds: CGRect = UIScreen.main.bounds
//            rightView.frame = CGRect(x: bounds.maxX-100, y: 0, width: 40, height: 20)
//            let like = UIButton(type:.system)
//            like.frame = CGRect(x:10, y:8, width: 20, height: 15)
//            if isLike{
//                like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//            }
//            else{
//                like.setImage(UIImage(systemName: "heart"), for: .normal)
//            }
//            like.tintColor = .red
//            like.addTarget(self, action: #selector(likePost(_:)), for: .touchUpInside)
//            // 라이트 뷰에 버튼 추가
//            rightView.addSubview(like)
//            let dislike = UIButton(type:.system)
//            dislike.frame = CGRect(x:50, y:8, width: 20, height: 15)
//            if isDislike{
//                dislike.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
//            }
//            else{
//                dislike.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
//            }
//            dislike.tintColor = .blue
//            dislike.addTarget(self, action: #selector(dislikePost(_:)), for: .touchUpInside)
//            // 라이트 뷰에 버튼 추가
//            rightView.addSubview(dislike)
//            return rightView
//        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = commentTable.dequeueReusableCell(withIdentifier: "DocumentDetailCell", for: indexPath) as! DocumentDetailCell
            cell.titleLabel.text = titleString
            cell.descriptionLabel.text = descriptionString
            cell.LikesButton.setTitle(String(likes), for: .normal)
            cell.DislikesButton.setTitle(String(dislikes), for: .normal)
            cell.CommentsButton.setTitle(String(comments_number), for: .normal)
            var temp = firstCell()
            cell.addSubview(temp)
            return cell
        }else{
            let cell = commentTable.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row]
            cell.UserNameLabel.text = comment.writer
            cell.DescriptionLabel.text = comment.description
            cell.thumbsUpBtn.titleLabel?.text = String(comment.thumbsUp)
            cell.thumbsDownBtn.titleLabel?.text = String(comment.thumbsDown)
//            cell.addSubview(restCell(cell: cell))
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
                self.likes = rep["likes_number"] as! Int
                self.dislikes = rep["dislikes_number"] as! Int
                self.isLike = rep["like"]! as! Bool
                print("isLike : ", self.isLike)
                self.isDislike = rep["dislike"] as! Bool
                print("isDislike : ", self.isDislike)
            case .failure(let value):
                print("like request Error")
            }
        }

    }
    
    @IBAction func likeComment(cell1: CommentCell){
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/commentLikes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        let time = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: time){
            self.refreshComment()
        }
        print("like btn clicked")
    }
    
    @objc func dislikeComment(){
        
    }
    
    
    @IBAction func likePost(_ sender: UIButton) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/likes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        let time = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: time){
            self.refreshComment()
        }
        likeRequest()
        if isLike{
            like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        else{
            like.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        print("like btn clicked")
    }
    
    @IBAction func dislikePost(_ sender: Any) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/dislikes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        let time = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: time){
            self.refreshComment()
        }
        likeRequest()
        if isDislike{
            dislike.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        else{
            dislike.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
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
    }
    
    @objc func refreshComment(){
        comments.removeAll()
        getComments()
        likeRequest()
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
