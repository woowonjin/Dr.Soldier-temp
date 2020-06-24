//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var user : User?
    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    var startDate : Date?
    var endDate : Date?
    var mTimer : Timer?
    var totalSecond : Double?
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    @IBOutlet weak var fitnessButton: UIButton!
    @IBOutlet weak var FinanceButton: UIButton!
    @IBOutlet weak var bodyButton: UIButton!
    @IBOutlet weak var goalButton: UIButton!
    
    @IBOutlet weak var GoalButtonText: UIButton!
    @IBOutlet weak var BodyButtonText: UIButton!
    @IBOutlet weak var FinanceButtonText: UIButton!
    @IBOutlet weak var FitnessButtonText: UIButton!
    
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var leftDays: UILabel!
    @IBOutlet weak var hadDays: UILabel!
    @IBOutlet weak var totalDays: UILabel!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var endLabel: UITextField!
    @IBOutlet weak var startLabel: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var ProgressBar: UIProgressView!
    @IBOutlet weak var profileImage: UIImageView!
    let imagePickerController = UIImagePickerController()
    
    func createDatePicker(){
        startLabel.textAlignment = .center
        endLabel.textAlignment = .center
        let startToolbar = UIToolbar()
        let endToolbar = UIToolbar()
        startToolbar.sizeToFit()
        endToolbar.sizeToFit()
        let startDoneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(startDonePressed))
        let endDoneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endDonePressed))
        startToolbar.setItems([startDoneBtn], animated: true)
        endToolbar.setItems([endDoneBtn], animated: true)
        startLabel.inputAccessoryView = startToolbar
        endLabel.inputAccessoryView = endToolbar
        startLabel.inputView = startDatePicker
        endLabel.inputView = endDatePicker
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
    }
    
    @objc func startDonePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: startDatePicker.date)
        self.startDate = dateFormatter.date(from: dateString)
        self.startLabel.text = dateString
        self.view.endEditing(true)
        self.renewDate()
    }
    
    @objc func endDonePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: endDatePicker.date)
        self.endDate = dateFormatter.date(from: dateString)
        self.endLabel.text = dateString
        self.view.endEditing(true)
        self.renewDate()
    }
    
    @IBAction func NavBtnClicked(_ sender: UIButton) {
        let nextMenu = sender.currentTitle!
        
        if let nextView = self.storyboard?.instantiateViewController(withIdentifier: nextMenu){
        self.navigationController?.pushViewController(nextView, animated: true)
        }
        
    }
    
    @IBAction func AlbumPush(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func timerCallback(){
        let now = Date()
        let percent = (now.timeIntervalSince(self.startDate!) / totalSecond!)
        percentLabel.text = String(format:"%.7f", percent*100) + "%"
        ProgressBar.setProgress(Float(percent), animated: true)
    }

    func renewDate(){
        guard let start = self.startDate else {
            return;
        }
        guard let end = self.endDate else {
            return;
        }
        self.totalSecond = end.timeIntervalSince(start)
        let totalDate = Int(end.timeIntervalSince(start)/(60*60*24))
        let now = Date()
        let fromNowDate = Int(now.timeIntervalSince(start)/(60*60*24))
        let leaveDate = totalDate-fromNowDate
        self.totalDays.text = String(totalDate)
        self.hadDays.text = String(fromNowDate)
        self.leftDays.text = String(leaveDate)
        print(totalDate)
        if let timer = mTimer {
                    //timer 객체가 nil 이 아닌경우에는 invalid 상태에만 시작한다
                    if !timer.isValid {
                        /** 1초마다 timerCallback함수를 호출하는 타이머 */
                        mTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                    }
                }else{
                    //timer 객체가 nil 인 경우에 객체를 생성하고 타이머를 시작한다
                    /** 1초마다 timerCallback함수를 호출하는 타이머 */
            mTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
           
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BeginButtonTap(_ sender: Any) {
        self.startLabel.becomeFirstResponder()
    }
    @IBAction func EndButtonTap(_ sender: Any) {
        self.endLabel.becomeFirstResponder()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        goalButton.imageView?.contentMode = .scaleAspectFit
        bodyButton.imageView?.contentMode = .scaleAspectFit
        FinanceButton.imageView?.contentMode = .scaleAspectFit
        fitnessButton.imageView?.contentMode = .scaleAspectFit
        
        
        GoalButtonText.tintColor = UIColor.systemGray
        GoalButtonText.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        BodyButtonText.tintColor = UIColor.systemGray
        BodyButtonText.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        FinanceButtonText.tintColor = UIColor.systemGray
        FinanceButtonText.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        FitnessButtonText.tintColor = UIColor.systemGray
        FitnessButtonText.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        imagePickerController.delegate = self
        let navview = MakeViewWithNavigationBar.init(InputString: " 닥터솔저", InputImage: UIImage(named: "doctor3.png")!)
        self.navigationItem.titleView = navview.navView
        createDatePicker()
        ProgressBar.tintColor = UIColor(red: 90/255.0, green: 193/255.0, blue: 142/255.0, alpha: 1)
        ProgressBar.backgroundColor = UIColor(red: 90/255.0, green: 193/255.0, blue: 142/255.0, alpha: 0.3)
    }
    


}

