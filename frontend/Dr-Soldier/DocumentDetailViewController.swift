//
//  DocumentDetailViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/05/01.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth

class DocumentDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
     private var refreshControl = UIRefreshControl()
    @IBOutlet weak var commentTextField: UITextField!
    //var user: User?
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentView: UIStackView!
    let like = UIButton(type:.system)
    let dislike = UIButton(type:.system)
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    let uid = Auth.auth().currentUser?.uid
    var userEmail : String? // UserDefault -> Sqlite
    var titleString : String = ""
    var descriptionString : String = ""
    var post_pk = -1
    var likes = 0;
    var dislikes = 0;
    var comments_number = 0;
    var isLike = false
    var isDislike = false
    var isCommentLike = false
    var isCommentDislike = false
    var comments : Array<Comment> = [
    ]
    let header: HTTPHeaders = [
        "Content-Type" : "application/json",
        "Charset" : "utf-8"
    ]
    
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTable: UITableView!
    func getComments(){
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/comments/?pk=\(self.post_pk)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let responseList = value as! Array<AnyObject>
                self.comments.insert(Comment(description: "댓글", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false, pk: -1), at: 0)
                for (index, _) in responseList.enumerated(){
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
            case .failure( _):
                print("maybe server down")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func firstCell()->UIView{
        let rightView = UIView()
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/alreadylikes/?pk=\(self.post_pk)&user=\(uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as AnyObject
                self.likes = rep["likes_number"] as! Int
                self.dislikes = rep["dislikes_number"] as! Int
                self.isLike = rep["like"]! as! Bool
                self.isDislike = rep["dislike"] as! Bool
                let bounds: CGRect = UIScreen.main.bounds
                rightView.frame = CGRect(x: bounds.maxX-100, y: 0, width: 80, height: 40)
                self.like.frame = CGRect(x:10, y:8, width: 30, height: 30)
                if self.isLike{
                    self.like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                else{
                    self.like.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                self.like.tintColor = UIColor(red: 255, green: 153, blue: 204)
                self.like.addTarget(self, action: #selector(self.likePost(_:)), for: .touchUpInside)
                rightView.addSubview(self.like)
                self.dislike.frame = CGRect(x:50, y:8, width: 30, height: 30)
                if self.isDislike{
                    self.dislike.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
                }
                else{
                    self.dislike.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
                }
                self.dislike.tintColor = UIColor(red: 153, green: 204, blue: 255)
                self.dislike.addTarget(self, action: #selector(self.dislikePost(_:)), for: .touchUpInside)
                // 라이트 뷰에 버튼 추가
                rightView.addSubview(self.dislike)
            case .failure( _):
                print("like request Error")
            }
        }
//        let rightView = UIView()
//        let bounds: CGRect = UIScreen.main.bounds
//        rightView.frame = CGRect(x: bounds.maxX-100, y: 0, width: 80, height: 40)
//        like.frame = CGRect(x:10, y:8, width: 30, height: 30)
//        if isLike{
//            like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//        }
//        else{
//            like.setImage(UIImage(systemName: "heart"), for: .normal)
//        }
//        like.tintColor = UIColor(red: 255, green: 153, blue: 204)
//        like.addTarget(self, action: #selector(likePost(_:)), for: .touchUpInside)
//        rightView.addSubview(like)
//        dislike.frame = CGRect(x:50, y:8, width: 30, height: 30)
//        if isDislike{
//            dislike.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
//        }
//        else{
//            dislike.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
//        }
//        dislike.tintColor = UIColor(red: 153, green: 204, blue: 255)
//        dislike.addTarget(self, action: #selector(dislikePost(_:)), for: .touchUpInside)
//        // 라이트 뷰에 버튼 추가
//        rightView.addSubview(dislike)
        return rightView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = commentTable.dequeueReusableCell(withIdentifier: "DocumentDetailCell", for: indexPath) as! DocumentDetailCell
            cell.titleLabel.text = titleString
            cell.descriptionLabel.text = descriptionString
            cell.LikesButton.setTitle(String(likes), for: .normal)
            cell.LikesButton.titleLabel?.textColor = UIColor(red: 255, green: 153, blue: 204)
            cell.LikesButton.tintColor = UIColor(red: 255, green: 153, blue: 204)
            cell.DislikesButton.setTitle(String(dislikes), for: .normal)
            cell.DislikesButton.titleLabel?.textColor = UIColor(red: 153, green: 204, blue: 255)
            cell.DislikesButton.tintColor = UIColor(red: 153, green: 204, blue: 255)
            cell.CommentsButton.setTitle(String(comments_number), for: .normal)
            cell.CommentsButton.titleLabel?.textColor = UIColor(red: 90, green: 193, blue: 142)
            cell.CommentsButton.tintColor = UIColor(red: 90, green: 193, blue: 142)
            self.like.tag = indexPath.row
            self.dislike.tag = indexPath.row
            let temp = firstCell()
            cell.addSubview(temp)
            return cell
        }else{
            let cell = commentTable.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row]
            cell.pk = comment.pk
            cell.UserNameLabel.text = comment.writer
            cell.DescriptionLabel.text = comment.description
            cell.thumbsUpBtn.setTitle(String(comment.thumbsUp), for: .normal)
            cell.thumbsUpBtn.titleLabel?.textColor = UIColor(red: 255, green: 153, blue: 204)
            cell.thumbsUpBtn.tintColor = UIColor(red: 255, green: 153, blue: 204)
            cell.thumbsDownBtn.setTitle(String(comment.thumbsDown), for: .normal)
            cell.thumbsDownBtn.titleLabel?.textColor = UIColor(red: 153, green: 204, blue: 255)
            cell.thumbsDownBtn.tintColor = UIColor(red: 153, green: 204, blue: 255)
            let bounds: CGRect = UIScreen.main.bounds
            let commentLike = UIButton(type:.system)
            let commentDislike = UIButton(type:.system)
            commentLike.frame = CGRect(x:bounds.maxX-100, y:8, width: 20, height: 15)
            commentLike.tintColor = UIColor(red: 255, green: 153, blue: 204)
            commentDislike.frame = CGRect(x:bounds.maxX-50, y:8, width: 20, height: 15)
            commentDislike.tintColor = UIColor(red: 153, green: 204, blue: 255)
            cell.likeBtn = commentLike
            cell.dislikeBtn = commentDislike

            self.commentLikeRequest(cell: cell)
            cell.dislikeBtn.addTarget(self, action: #selector(dislikeComment), for: .touchUpInside)
            cell.likeBtn.tag = indexPath.row
            cell.dislikeBtn.tag = indexPath.row
            cell.likeBtn.addTarget(self, action: #selector(likeComment), for: .touchUpInside)
            cell.addSubview(cell.likeBtn)
            cell.addSubview(cell.dislikeBtn)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func likeRequest(){
//        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/alreadylikes/?pk=\(self.post_pk)&user=\(uid!)").responseJSON { response in
//            switch response.result{
//            case .success(let value):
//                let rep = value as AnyObject
//                self.likes = rep["likes_number"] as! Int
//                self.dislikes = rep["dislikes_number"] as! Int
//                self.isLike = rep["like"]! as! Bool
//                self.isDislike = rep["dislike"] as! Bool
//            case .failure( _):
//                print("like request Error")
//            }
//        }
//
//    }
    
    func commentLikeRequest(cell: CommentCell){
        let userEmail:String = self.userEmail!
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/alreadyCommentLikes/?pk=\(cell.pk!)&user=\(uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as AnyObject
                let temp_like = rep["likes_number"] as! Int
                let temp_dislike = rep["dislikes_number"] as! Int
                cell.likeBtn.setTitle(String(temp_like), for: .normal)
                cell.dislikeBtn.setTitle(String(temp_dislike), for: .normal)
                cell.isLike = rep["like"]! as! Bool
                cell.isDislike = rep["dislike"] as! Bool
                if cell.isLike{
//                    self.comments[cel l.likeBtn.tag].isLike = true
                    cell.likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
//                    cell.likeBtn.isSelected = true
                }
                else{
//                    self.comments[cell.likeBtn.tag].isLike = false
                    cell.likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
//                    cell.likeBtn.isSelected = false
                }
                if cell.isDislike{
//                    self.comments[cell.dislikeBtn.tag].isDislike = true
                    cell.dislikeBtn.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
//                    cell.dislikeBtn.isSelected = true
                }
                else{
//                    self.comments[cell.dislikeBtn.tag].isDislike = false
                    cell.dislikeBtn.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
//                    cell.dislikeBtn.isSelected = false
                }
            case .failure( _):
                print("commentLike request Error")
            }
        }
    }
    
    @IBAction func likeComment(_ sender: UIButton){
        let userEmail:String = self.userEmail!
        // let user = UserDefaults.standard.dictionary(forKey: "user")
        let cell = comments[sender.tag]
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/commentLikes/?pk=\(cell.pk)&user=\(uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as AnyObject
                let type = rep["result"] as! String
                if(type == "create"){
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentCell
                    self.comments[sender.tag].thumbsUp += 1
                    cell.thumbsUpBtn.setTitle(String(self.comments[sender.tag].thumbsUp), for: .normal)
                    cell.likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=comment_like").responseJSON { response in
                    }
                }
                else if(type == "delete"){
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentCell
                    self.comments[sender.tag].thumbsUp -= 1
                    cell.thumbsUpBtn.setTitle(String(self.comments[sender.tag].thumbsUp), for: .normal)
                    cell.likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=comment_like_cancel").responseJSON { response in
                    }
                }
            case .failure( _):
                print("something wrong")
            }
        }
        print("commentLike btn clicked")
    }
    
    @IBAction func dislikeComment(_ sender: UIButton){
        // let user = UserDefaults.standard.dictionary(forKey: "user")
        let cell = comments[sender.tag]
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/commentDislikes/?pk=\(cell.pk)&user=\(self.uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as AnyObject
                let type = rep["result"] as! String
                if(type == "create"){
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentCell
                    self.comments[sender.tag].thumbsDown += 1
                    cell.thumbsDownBtn.setTitle(String(self.comments[sender.tag].thumbsDown), for: .normal)
                    cell.dislikeBtn.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=comment_dislike").responseJSON { response in
                    }
                }
                else if(type == "delete"){
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommentCell
                    self.comments[sender.tag].thumbsDown -= 1
                    cell.thumbsDownBtn.setTitle(String(self.comments[sender.tag].thumbsDown), for: .normal)
                    cell.dislikeBtn.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=comment_dislike_cancel").responseJSON { response in
                    }
                }
            case .failure( _):
                print("something wrong")
            }
        }
        print("commentDislike btn clicked")
    }
    
    
    @IBAction func likePost(_ sender: UIButton) {
        //let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/likes/?pk=\(self.post_pk)&user=\(self.uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as AnyObject
                let type = rep["result"] as! String
                if(type == "create"){
                    self.likes += 1
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! DocumentDetailCell
                    cell.LikesButton.setTitle(String(self.likes), for: .normal)
                    self.like.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=like").responseJSON { response in
                    }
                }
                else if(type == "delete"){
                    self.likes -= 1
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! DocumentDetailCell
                    cell.LikesButton.setTitle(String(self.likes), for: .normal)
                    self.like.setImage(UIImage(systemName: "heart"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=like_cancel").responseJSON { response in
                    }
                }
            case .failure( _):
                print("something wrong")
            }
        }
        print("like btn clicked")
    }
    
    @IBAction func dislikePost(_ sender: Any) {
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/dislikes/?pk=\(self.post_pk)&user=\(self.uid!)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let rep = value as AnyObject
                let type = rep["result"] as! String
                if(type == "create"){
                    self.dislikes += 1
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! DocumentDetailCell
                    cell.DislikesButton.setTitle(String(self.dislikes), for: .normal)
                    self.dislike.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=dislike").responseJSON { response in
                    }
                }
                else if(type == "delete"){
                    self.dislikes -= 1
                    let cell = self.commentTable.cellForRow(at: IndexPath(row: 0, section: 0)) as! DocumentDetailCell
                    cell.DislikesButton.setTitle(String(self.dislikes), for: .normal)
                    self.dislike.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
                    AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=dislike_cancel").responseJSON { response in
                    }
                }
            case .failure( _):
                print("something wrong")
            }
        }
        print("dislike btn clicked")
    }
    
    @objc private func keyboardWillShow(_ notification: Foundation.Notification) {
      if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
        let keybaordRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keybaordRectangle.height
        self.commentView.frame.origin.y -= keyboardHeight-45
      }
    }
    
    @objc private func keyboardWillHide(_ notification: Foundation.Notification) {
      if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
        let keybaordRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keybaordRectangle.height
        self.commentView.frame.origin.y += keyboardHeight-45
      }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func placeholderSetting() {
            commentTextView.delegate = self // txtvReview가 유저가 선언한 outlet
            commentTextView.text = "댓글을 입력하세요."
            commentTextView.textColor = UIColor.lightGray
            
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
    
    @objc func viewTapped(gestureReconizer: UIGestureRecognizer){
        commentTextView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.viewTapped(gestureReconizer:)))
        self.view.addGestureRecognizer(gesture)
        //키보드 조정
//        self.commentTextField.delegate = self
        self.commentTextView.layer.borderWidth = 0.8
        self.commentTextView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        self.commentTextView.layer.cornerRadius = 5
        placeholderSetting()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        let result = self.DB.query(statement: self.Query.SelectStar(Tablename: "User") , ColumnNumber: 6)
        self.userEmail = result[0][0]
        commentTable.refreshControl = refreshControl
        self.refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refreshComment), for: .valueChanged)
//        getComments()
//        likeRequest()
        self.commentView.translatesAutoresizingMaskIntoConstraints = false
        commentTable.delegate = self
        commentTable.dataSource = self
        commentTable.estimatedRowHeight = 100
        commentTable.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        comments.removeAll()
        getComments()
//        likeRequest()
        commentTable.reloadData()
    }
    
    @objc func refreshComment(){
        comments.removeAll()
        getComments()
//        likeRequest()
        commentTable.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        //let user = UserDefaults.standard.dictionary(forKey: "user")
        if(self.commentTextView.text != nil && self.commentTextView.text! != ""){
            let userEmail:String = self.userEmail!
            let params : Parameters = [ "content":commentTextView.text!]
            
            let url = "http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/comments/create/"
                    
            let info = url + "?content=\(params["content"]!)&pk=\(self.post_pk)&user=\(self.uid!)"
            AF.request(info.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "",
                        method: .post, parameters: params, headers: header).responseJSON { response in
            }
            let time = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: time){
                self.refreshComment()
            }
            self.commentTextView.text = ""
            AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/notification/?post_pk=\(self.post_pk)&user=\(self.uid!)&type=comment").responseJSON { response in
            }
            self.commentTextView.resignFirstResponder()
        }
    }
    
}
