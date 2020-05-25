//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class FitnessViewController: UIViewController {

    @IBOutlet weak var pushupLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var situpLabel: UILabel!
    @IBOutlet weak var situpSlider: UISlider!
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()

    override func viewDidLoad() {
           super.viewDidLoad()
           // Do any additional setup after loading the view.
           let navview = Variable_Functions.init()
           self.navigationItem.titleView = navview.navView
           
           print("-----------------")
           print(DB.database)
           print(DB.query(statement: Query.SelectStar(Tablename: "Fitness"), ColumnNumber: 4))
           print("-----------------")
    
       }
    
    @IBAction func RunChanged(_ sender: UISlider) {
        runLabel.text = String(Int(sender.value))
    }
    @IBAction func PushupChanged(_ sender: UISlider) {
        pushupLabel.text = String(Int(sender.value))
    }
    @IBAction func SitupChanged(_ sender: UISlider) {
        situpLabel.text = String(Int(sender.value))
    }
    
    @IBAction func SubmitButtonPushed(_ sender: Any) {
        let run = runLabel.text!
        let pushup = pushupLabel.text!
        let situp = situpLabel.text!
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        print(DB.query(statement: "SELECT * FROM Fitness", ColumnNumber: 4))
        print("---------")
        if DB.query(statement: "SELECT * FROM Fitness WHERE checked_date = '\(dateString)'", ColumnNumber: 4).count == 0{
            DB.insert(statement: "INSERT INTO Fitness (checked_date, pushup, situp, run) VALUES( '\(dateString)','\(pushup)', '\(situp)', '\(run)' )")
        }else{
            DB.update(statement: "UPDATE Fitness SET pushup='\(pushup)', situp = '\(situp)', run = '\(run)' WHERE checked_date = '\(dateString)'")
        }
        
        
    }
}

