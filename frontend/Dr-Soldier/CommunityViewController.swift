//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire

class CommunityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    private var refreshControl = UIRefreshControl()
    var page = 1
    
    var user: User?
    @IBOutlet weak var mainTableView: UITableView!
    var docs : Array<Document> = []
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docs.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == self.page*20-6){
            self.page += 1
            getDocs()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! DocumentCell
        let document = docs[indexPath.row]
        cell.titleLabel.text = document.title
        cell.descriptionLabel.text = document.description
        cell.informationLabel.text = document.writer + " | " + document.created
        cell.thumbsUpBtn.setTitle(String(document.thumbsUp), for: .normal)
        cell.thumbsUpBtn.titleLabel?.textColor = UIColor(red: 255, green: 153, blue: 204)
        cell.thumbsUpBtn.tintColor = UIColor(red: 255, green: 153, blue: 204)
        cell.thumbsDownBtn.setTitle(String(document.thumbsDown), for: .normal)
        cell.thumbsDownBtn.titleLabel?.textColor = UIColor(red: 153, green: 204, blue: 255)
        cell.thumbsDownBtn.tintColor = UIColor(red: 153, green: 204, blue: 255)
        cell.commentsBtn.setTitle(String(document.comments), for: .normal)
        cell.commentsBtn.titleLabel?.textColor = UIColor(red: 90, green: 193, blue: 142)
        cell.commentsBtn.tintColor = UIColor(red: 90, green: 193, blue: 142)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentDetailViewController") as! DocumentDetailViewController
            let document = docs[indexPath.row]
            nextView.post_pk = document.pk
            nextView.likes = document.thumbsUp
            nextView.dislikes = document.thumbsDown
            nextView.comments_number = document.comments
            nextView.titleString = document.title
            nextView.descriptionString = document.description
            self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getDocs(){
        //self.docs.insert(Document(title: "헬로우 스위프트~", description: "킾고잉~ 코더스하이!", created: "temp", writer: "관리자", thumbsUp: 0, thumbsDown: 0, isDeleted: false, pk: 1), at: 0)
        print("GET Docs")
        AF.request("http://dr-soldier.eba-8wqpammg.ap-northeast-2.elasticbeanstalk.com/documents/?page=\(page)").responseJSON { response in
            switch response.result{
            case .success(let value):
                print("success")
                let responseList = value as! Array<AnyObject>
                
                let dateFormatter = DateFormatter()
                let now = Date()
                dateFormatter.dateFormat="yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                
                for (index, _) in responseList.enumerated(){
                    //let obj = element["fields"] as! AnyObject
                    let title = responseList[index]["title"] as! String
                    let description = responseList[index]["text"] as! String
                    let likes = responseList[index]["likes_number"] as! Int
                    let dislikes = responseList[index]["dislikes_number"] as! Int
                    let comments = responseList[index]["comments_number"] as! Int
                    let writer = responseList[index]["host_name"] as! String
                    //let host = responseList[index]["host"] as! String
                    let created = responseList[index]["created"] as! String
                    let end = created.index(created.endIndex, offsetBy: -7)
                    let pk = responseList[index]["pk"] as! Int
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
                    
                    self.docs.insert(Document(title: title, description: description, created: createdStr, writer: writer, thumbsUp: likes, thumbsDown: dislikes, isDeleted: false, pk: pk, comments: comments), at: index+(self.page-1)*20)
                    DispatchQueue.main.async {
                        self.mainTableView.reloadData()
                    }
                }
            case .failure( _):
                print("maybe server down")
            }
        }
    }
    
    @objc func writeButtonClicked(){
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as! WriteViewController
         self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func refresh(){
        docs.removeAll()
        self.page = 1
        getDocs()
        mainTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.refreshControl = refreshControl
        self.refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        let navview = MakeViewWithNavigationBar.init(InputString: " Community",InputImage: UIImage(named: "soldier")!)
        self.navigationItem.titleView = navview.navView
        getDocs()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        // 라이트 뷰 생성
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        // rItem이라는 UIBarButtonItem 객체 생성
        let rItem = UIBarButtonItem(customView: rightView)
        self.navigationItem.rightBarButtonItem = rItem
        // 글쓰기 버튼 생성
        let writeButton = UIButton(type:.system)
        writeButton.frame = CGRect(x:10, y:8, width: 30, height: 30)
        writeButton.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        writeButton.tintColor = .white
        writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
        // 라이트 뷰에 버튼 추가
        rightView.addSubview(writeButton)
        
    }


}


