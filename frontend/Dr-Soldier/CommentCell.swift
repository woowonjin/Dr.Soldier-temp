//
//  DocumentCell.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/24.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class CommentCell : UITableViewCell{
    var pk: Int!
    var isLike: Bool = false
    var isDislike: Bool = false
    
//    var vc: DocumentDetailViewController!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var InformationLabel: UILabel!
    @IBOutlet weak var thumbsUpBtn: UIButton!
    @IBOutlet weak var thumbsDownBtn: UIButton!
//    @IBAction func likeClicked(_ sender: UIButton){
//        print("!!!like!!!")
//        vc.likeComment(cell: self)
//    }
//    @IBAction func dislikeClicked(_ sender: UIButton){
//        print("dislike")
//        vc.dislikeComment(cell: self)
//    }
}
