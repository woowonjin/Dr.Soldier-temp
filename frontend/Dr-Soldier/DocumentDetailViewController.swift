//
//  DocumentDetailViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/05/01.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class DocumentDetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var titleString : String = ""
    var descriptionString : String = ""
    var comments : Array<Comment> = [
        Comment(description: "댓글", created: Date(), writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
        Comment(description: "댓글2", created: Date(), writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
        Comment(description: "댓글3", created: Date(), writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
        Comment(description: "댓글4", created: Date(), writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
        Comment(description: "댓글5", created: Date(), writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
        Comment(description: "댓글6", created: Date(), writer: "leedh2004", thumbsUp: 100, thumbsDown: 100, isDeleted: false),
    ]
    
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var commentTable: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = commentTable.dequeueReusableCell(withIdentifier: "DocumentDetailCell", for: indexPath) as! DocumentDetailCell
            cell.titleLabel.text = titleString
            cell.descriptionLabel.text = descriptionString
            
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

    override func viewDidLoad() {
        super.viewDidLoad()
        commentTable.delegate = self
        commentTable.dataSource = self
        
        commentTable.estimatedRowHeight = 100
        commentTable.rowHeight = UITableView.automaticDimension
        
    }
}
