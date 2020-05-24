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
    var user: User?
    var titleString : String = ""
    var descriptionString : String = ""
    var post_pk = -1
    var likes = 0;
    var dislikes = 0;
    var comments_number = 0;
    var comments : Array<Comment> = [
        Comment(description: "댓글", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
//        Comment(description: "댓글2", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
//        Comment(description: "댓글3", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
//        Comment(description: "댓글4", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
//        Comment(description: "댓글5", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
//        Comment(description: "댓글6", created: "방금", writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
    ]
    
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTable: UITableView!

    func getComments(){
        AF.request("http://127.0.0.1:8000/comments/?pk=\(self.post_pk)").responseJSON { response in
            switch response.result{
            case .success(let value):
                let responseList = value as! Array<AnyObject>
            
                for (index, element) in responseList.enumerated(){
                    let text = responseList[index]["text"] as! String
                    let writer = responseList[index]["host_name"] as! String
                    let likes = responseList[index]["likes_number"] as! Int
                    let disLikes = responseList[index]["dislikes_number"] as! Int
                    
                    self.comments.insert(Comment(description: text, created: "방금", writer: writer, thumbsUp: likes, thumbsDown: disLikes, isDeleted: false), at: index+1)
                }
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
        
            cell.LikesButton.titleLabel?.text = String(likes)
            cell.DislikesButton.titleLabel?.text = String(dislikes)
            cell.CommentsButton.titleLabel?.text = String(comments_number)
            return cell
        }else{
            let cell = commentTable.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            let comment = comments[indexPath.row]
            cell.UserNameLabel.text = comment.writer
            cell.DescriptionLabel.text = comment.description
//            cell.thumbsUpBtn.titleLabel?.text = String(comment.thumbsUp)
//            cell.thumbsDownBtn.titleLabel?.text = String(comment.thumbsDown)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func likePost(_ sender: Any) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/likes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        print("like btn clicked")
    }
    
    @IBAction func dislikePost(_ sender: Any) {
        let user = UserDefaults.standard.dictionary(forKey: "user")
        AF.request("http://127.0.0.1:8000/dislikes/?pk=\(self.post_pk)&user=\((user!["email"])! as! String)").responseJSON { response in
        }
        print("dislike btn clicked")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getComments()
    
        commentTable.delegate = self
        commentTable.dataSource = self
        commentTable.estimatedRowHeight = 100
        commentTable.rowHeight = UITableView.automaticDimension
    }
}
