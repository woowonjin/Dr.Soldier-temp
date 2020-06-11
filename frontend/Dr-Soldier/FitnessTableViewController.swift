//
//  FitnessTableViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/06/03.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class FitnessTableViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTable: UITableView!
    var datas : Array<Array<String>> = []
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTable.dequeueReusableCell(withIdentifier: "FitnessTableCell", for: indexPath) as! FitnessTableCell
        cell.dateLabel.text = datas[indexPath.row][0]
        cell.situpLabel.text = datas[indexPath.row][1]
        cell.pushupLabel.text = datas[indexPath.row][2]
        cell.runLabel.text = datas[indexPath.row][3]+"분"+datas[indexPath.row][4]+"초"
        cell.pk = datas[indexPath.row][5]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTable.delegate = self
        mainTable.dataSource = self
        datas = DB.query(statement: Query.SelectStar(Tablename: "Fitness"), ColumnNumber: 6)
    }

    @IBAction func buttonTapped(_ sender: Any) {
        datas = DB.query(statement: Query.SelectStar(Tablename: "Fitness"), ColumnNumber: 6)
        mainTable.reloadData()
    }
    
}

class FitnessTableCell:UITableViewCell{
    var pk:String?
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var pushupLabel: UILabel!
    @IBOutlet weak var situpLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    
    @IBAction func RemoveBtnTapped(_ sender: Any) {
        DB.delete(statement: Query.Delete(Tablename: "Fitness", Condition: "pk = '\(pk!)'"))
    }
}

struct FitnessData{
    let date : String
    let pushup : String
    let situp : String
    let run : String
}
