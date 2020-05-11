//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Alamofire

class CommunityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var docs : Array<Document> = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! DocumentCell
        let document = docs[indexPath.row]
        cell.titleLabel.text = document.title
        cell.descriptionLabel.text = document.description
        cell.informationLabel.text = "5분 전 | " + document.writer
        cell.thumbsUpBtn.titleLabel?.text = String(document.thumbsUp)
        cell.thumbsDownBtn.titleLabel?.text = String(document.thumbsDown)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextView = self.storyboard?.instantiateViewController(withIdentifier: "DocumentDetailViewController") as! DocumentDetailViewController
        let document = docs[indexPath.row]
        nextView.titleString = document.title
        nextView.descriptionString = document.description
        self.navigationController?.pushViewController(nextView, animated: true)
        
    }
    
    func getDocs(){
        self.docs.insert(Document(title: "헬로우 스위프트~", description: "킾고잉~ 코더스하이!", created: Date(), writer: "관리자", thumbsUp: 0, thumbsDown: 0, isDeleted: false), at: 0)
        AF.request("http://127.0.0.1:8000/documents").responseJSON { response in
            switch response.result{
            case .success(let value):
                let responseList = value as! Array<AnyObject>
                for (index, element) in responseList.enumerated(){
                    let obj = element["fields"] as! AnyObject
                    let title = obj["title"] as! String
                    let description = obj["text"] as! String
                    self.docs.insert(Document(title: title, description: description, created: Date(), writer: "leedh2004", thumbsUp: 30, thumbsDown: 10, isDeleted: false), at: index)
                }
            case .failure(let error):
                print("maybe server down")
            }
//            let responseList = response.value as! Array<AnyObject>
//            for (index, element) in responseList.enumerated(){
//                let obj = element["fields"] as! AnyObject
//                let title = obj["title"] as! String
//                let description = obj["text"] as! String
//                self.docs.insert(Document(title: title, description: description, created: Date(), writer: "leedh2004", thumbsUp: 30, thumbsDown: 10, isDeleted: false), at: index)
//            }
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
           
        }
        print("getDocs()!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.leftBarButtonItem = nil;
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
        getDocs()
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }


}


