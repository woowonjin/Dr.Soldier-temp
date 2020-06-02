//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var successButton: UIButton!
    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    var Data : Array<Array<String>> = []
    let SegmentedBarColor = [UIColor.init(rgb:0x5AC18E),UIColor.init(rgb: 0xff7373) , UIColor.init(rgb: 0xe8a87c) ,UIColor.init(rgb: 0x22A39F), UIColor.clear]
    

    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var Label: UILabel!
    
    
    @IBAction func SuccessButtonTap(_ sender: Any) {
        update()
    }
    
    @IBAction func DeleteButtonTap(_ sender: Any) {
        update()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Table.dequeueReusableCell(withIdentifier: "ToDoListTableCell", for: indexPath) as! ToDoListTableCell
        cell.Discription.text = Data[indexPath.row][0]
        cell.DiscriptionLocal = Data[indexPath.row][0]
        cell.Is_Success = Data[indexPath.row][1]
        cell.Discription.numberOfLines = 0
        cell.Discription.lineBreakMode = NSLineBreakMode.byWordWrapping;
        cell.Discription.sizeToFit()
        
        cell.Discription.font = UIFont.boldSystemFont(ofSize: 15)
        if Data[indexPath.row][1] == "1" {
            cell.backgroundColor = SegmentedBarColor[0]
            cell.Discription.textColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor.clear
            cell.Discription.textColor = UIColor.black
        }
        //print(Data[indexPath.row])
        return cell
    }
    

    override func viewDidLoad() {
       super.viewDidLoad()
       // Do any additional setup after loading the view.
        
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
        update()
        Table.rowHeight = UITableView.automaticDimension
        Table.delegate = self
        Table.dataSource = self
        Label.numberOfLines = 3
        Label.sizeToFit()
        
        TextView.delegate = self
        TextView.returnKeyType = .done
    }
    
    func Button_Tap_f(){
        if TextView.text == "" {
            return
        }
        if DB.insert(statement: Quary.insert(Tablename: "Todo", Values: "'\(TextView.text!)','0'" )){
            print("Todolist insert success")
        }else{
            print("Todolist insert fail")
        }
        update()
    }
    
    //입력버튼
    @IBAction func Button_Tap(_ sender: Any) {
        Button_Tap_f()
    }
    
    //바로 삭제 가능
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
             Button_Tap_f()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        textView.text = ""
        textView.textAlignment = NSTextAlignment.left
    }

    
    func update() {
        
        //table
        Data = DB.query(statement: Quary.SelectStar(Tablename: "Todo") , ColumnNumber: 2)
        Data.sort { (arr1, arr2) -> Bool in
            if arr1[1] == "0" && arr2[1] == "1"{
                return true
            }else if arr1[1] == "1" && arr2[1] == "0"{
                return false
            }else{
                return true
            }
        }
        Table.reloadData()
        
        //text
        TextView.textColor = UIColor.gray
        TextView.text = "목표를 추가하세요 ✎"
        TextView.textAlignment = NSTextAlignment.center
        
        //label
        var complete = 0
        if Data.count == 0 {
            Label.text = "군생활 동안 이룰 목표를 세워봐요. \n 닥터가 응원할게요!"
        }else{
            for each in Data{
                if each[1] == "1"{
                    complete += 1
                }
            }
            if Data.count == complete {
                Label.text = "총 \(Data.count) 개의 목표를 모두 이루셨군요. \n 정말 축하드려요!"
            }else{
                 Label.text = "총 \(Data.count) 개의 목표중에 \n \(complete) 개의 목표를 이루었습니다.\n 남은목표를 위해 노력해봅시다!"
            }
        }
        Label.sizeToFit()
        Label.font = UIFont.boldSystemFont(ofSize: 15)
        let attributedStr = NSMutableAttributedString(string: Label.text!)
        
        attributedStr.addAttribute(.foregroundColor, value:SegmentedBarColor[0]  , range: (Label.text! as NSString).range(of: "\(Data.count)"))
        
        attributedStr.addAttribute(.foregroundColor, value: SegmentedBarColor[0] , range: (Label.text! as NSString).range(of: "\(complete)"))
      
        attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "\(Data.count)"))
        attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "\(complete)"))
        Label.attributedText = attributedStr
        
    }
}

class ToDoListTableCell: UITableViewCell {
     
    var DiscriptionLocal: String?
    var Is_Success : String?
    
    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    
    @IBOutlet weak var Discription: UILabel!
    @IBOutlet weak var Success: UIButton!
    @IBOutlet weak var Delete: UIButton!
    
    @IBAction func SuccessButtonTab(_ sender: Any) {
        if Is_Success! == "0" {
            if DB.update(statement: Quary.update(Tablename: "Todo", beforeValues: "goal = '\(DiscriptionLocal!)'", afterValues: "completed = '1'")){
                print("Success update success")
            }else{
                print("fail update success")
            }
        } else{
            if DB.update(statement: Quary.update(Tablename: "Todo", beforeValues: "goal = '\(DiscriptionLocal!)'", afterValues: "completed = '0'")){
               print("Success update success")
           }else{
               print("fail update success")
           }
        }
    }
    
    @IBAction func DeleteButtonTab(_ sender: Any) {
        if DB.delete(statement: Quary.Delete(Tablename: "Todo", Condition: "goal = '\(DiscriptionLocal!)'")){
            print("Success to delete to do list")
        }else{
            print("fail to delete to do list")
        }
    }
}

