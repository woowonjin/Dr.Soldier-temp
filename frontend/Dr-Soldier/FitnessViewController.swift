//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class FitnessViewController: UIViewController,  UIPickerViewDelegate , UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("pickerViewCount")
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("pickerViewRow")
        return pickerData[row]
    }

    // 피커뷰에서 선택시 호출
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerViewSelect")
        selectGoal = pickerData[row]
        print(selectGoal)
    }
    
    let pickerData = ["특급" , "1급" , "2급" , "3급"]  // 피커뷰에 보여줄 테스트 데이터
    var selectGoal = "특급"
    var level = 0
    var totalSeconds = 0
    
    @IBOutlet weak var runCheckedBtn: UIButton!
    @IBOutlet weak var pushupCheckedBtn: UIButton!
    @IBOutlet weak var situpCheckedBtn: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var situpSlider: UISlider!
    @IBOutlet weak var pushupSlider: UISlider!
    @IBOutlet weak var runSlider: UISlider!
    
    @IBAction func situpCheckedBtn(_ sender: Any) {
    }
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var pushupTextField: UITextField!
    @IBOutlet weak var situpTextField: UITextField!
    @IBOutlet weak var runMinuteTextField: UITextField!
    @IBOutlet weak var runSecondTextField: UITextField!
    
    @IBOutlet weak var resultLabel: UILabel!
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var Datas : Array<Data> = []
    let pickerView = UIPickerView()
    
    let situps = [86, 78, 70, 62]
    let pushups = [72, 64, 56, 48]
    let runs : Array<Float> = [100.0, 92.59, 86.20, 80.64]
    
    override func viewDidLoad() {
        super.viewDidLoad()
           // Do any additional setup after loading the view.
        let navview = MakeViewWithNavigationBar.init(InputString: "체력검정")
        self.navigationItem.titleView = navview.navView

        situpSlider.value = 40.0
        pushupSlider.value = 40.0
        runSlider.value = 40.0

        //초기값 설정
        situpTextField.text
        = String(Int(situpSlider.value))
        pushupTextField.text = String(Int(pushupSlider.value))
        runSecondTextField.text = String(Int(runSlider.value))

        self.submitButton.backgroundColor = UIColor.init(rgb:0x5AC18E)
        self.submitButton.tintColor = UIColor.white
        self.submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)

        pickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
        pickerView.delegate = self
        pickerView.dataSource = self

       // 피커뷰 툴바추가
       let pickerToolbar : UIToolbar = UIToolbar()
       pickerToolbar.barStyle = .default
       pickerToolbar.isTranslucent = true  // 툴바가 반투명인지 여부 (true-반투명, false-투명)
       pickerToolbar.backgroundColor = .lightGray
       pickerToolbar.sizeToFit()   // 서브뷰만큼 툴바 크기를 맞춤
       // 피커뷰 툴바에 확인/취소 버튼추가
       let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
       let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
       let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
       pickerToolbar.setItems([btnCancel , space , btnDone], animated: true)   // 버튼추가
       pickerToolbar.isUserInteractionEnabled = true   // 사용자 클릭 이벤트 전달
       
       goalTextField.inputView = pickerView // 피커뷰 추가
       goalTextField.inputAccessoryView = pickerToolbar // 피커뷰 툴바 추가
        goalTextField.text = selectGoal
        totalSecondsUpdate()
        runMinuteTextField.text = String(totalSeconds/60)
        runSecondTextField.text = String(totalSeconds%60)
        if DB.query(statement: "SELECT * FROM Level", ColumnNumber: 1).count == 0 {
            let _ = DB.insert(statement: "INSERT INTO Level (Level) VALUES( '\(0)' )")
        }else{
            level = Int(DB.query(statement: "SELECT * FROM Level", ColumnNumber: 1)[0][0]) ?? 0
            if(level == 1){
                goalTextField.text = "1급"
            }else if(level == 2){
                goalTextField.text = "2급"
            }else if(level == 3){
                goalTextField.text = "3급"
            }
        }
        let datas = DB.query(statement: "SELECT * FROM Fitness", ColumnNumber: 6)
        if(datas.count != 0){
            situpTextField.text = datas[datas.count-1][1]
            situpSlider.value = Float(datas[datas.count-1][1])!
            pushupTextField.text = datas[datas.count-1][2]
            pushupSlider.value = Float(datas[datas.count-1][2])!
            runMinuteTextField.text = datas[datas.count-1][3]
            runSecondTextField.text = datas[datas.count-1][4]
            totalSeconds = 60 * Int(runMinuteTextField.text!)! + Int(runSecondTextField.text!)!
            runSliderValueUpdate()
            
        }
        
        update()
    }
    
    @objc func onPickDone() {
        print("PICK DONE")
        print(selectGoal)
        goalTextField.text = selectGoal
        goalTextField.resignFirstResponder()
        update()
    }
    
    // 피커뷰 > 취소 클릭
    @objc func onPickCancel() {
        goalTextField.resignFirstResponder() // 피커뷰를 내림 (텍스트필드가 responder 상태를 읽음)
        print("PICK CANCEL")
        
    }
    
    @IBAction func RunChanged(_ sender: UISlider) {
        totalSecondsUpdate()
        runMinuteTextField.text = String(totalSeconds/60)
        runSecondTextField.text = String(totalSeconds%60)
        update()
    }
    @IBAction func PushupChanged(_ sender: UISlider) {
        pushupTextField.text = String(Int(sender.value))
        update()
    }
    @IBAction func SitupChanged(_ sender: UISlider) {
        situpTextField.text = String(Int(sender.value))
        update()
    }
    
    @IBAction func SitupTextFieldChanged(_ sender: Any) {
        situpSlider.value = Float(situpTextField.text!)!
        update()
    }
    @IBAction func RunSecTextFieldChanged(_ sender: Any) {
        totalSeconds = Int(runSecondTextField.text!)! + Int(runMinuteTextField.text!)!*60
        runSliderValueUpdate()
        update()
    }
    @IBAction func RunMinTextFieldChanged(_ sender: Any) {
        totalSeconds = Int(runSecondTextField.text!)! + Int(runMinuteTextField.text!)!*60
        runSliderValueUpdate()
        update()
    }
    @IBAction func PushUpTextFieldChanged(_ sender: Any) {
        pushupSlider.value = Float(pushupTextField.text!)!
        update()
    }
    @IBAction func SubmitButtonPushed(_ sender: Any) {
        let runMinute = runMinuteTextField.text!
        let runSecond = runSecondTextField.text!
        let pushup = pushupTextField.text!
        let situp = situpTextField.text!
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let pkArray = DB.query(statement: "SELECT * FROM Fitness", ColumnNumber: 6)
        let pk : Int
        if(pkArray.count == 0){
            pk = 0
        }else{
            pk = Int(pkArray[pkArray.count-1][5])! + 1
        }
        print(pk)
        print(DB.query(statement: "SELECT * FROM Level", ColumnNumber: 1))
        print("=========")
        print(DB.query(statement: "SELECT * FROM Fitness", ColumnNumber: 6))
        print("---------")

        let _ = DB.insert(statement: "INSERT INTO Fitness (checked_date, pushup, situp, runMinute, runSecond, pk) VALUES( '\(dateString)','\(pushup)', '\(situp)', '\(runMinute)', '\(runSecond)', '\(pk)')")
        let _ = DB.update(statement: "UPDATE Level SET level = '\(level)' WHERE level >= 0 ")

    }
    func runSliderValueUpdate(){
        let a = 75000
        let value = a / totalSeconds
        runSlider.value = Float(value)
    }
    
    func totalSecondsUpdate() {
        let a = 75000
        let value = runSlider.value
        
        let b = a / Int(value)
        totalSeconds = b
    }
    
    func update(){
        
        if(selectGoal == "1급"){ level = 1 }
        else if(selectGoal == "2급"){ level = 2}
        else if(selectGoal == "3급"){level = 3}
        print("LEVEL IS \(level)")
        var flag = true
        
        if(Int(situpSlider.value) >= situps[level]){
            if let image = UIImage(named: "tick.png") {
                situpCheckedBtn.setImage(image, for: [])
            }
        }else{
            flag = false
            if let image = UIImage(named: "tick-clicked.png") {
                situpCheckedBtn.setImage(image, for: [])
            }
            print("DEBUG")
        }
        
        if(Int(pushupSlider.value) >= pushups[level]){
            if let image = UIImage(named: "tick.png") {
                pushupCheckedBtn.setImage(image, for: [])
            }
        }else{
            flag = false
            if let image = UIImage(named: "tick-clicked.png") {
                pushupCheckedBtn.setImage(image, for: [])
            }
        }
        
        if(runSlider.value >= runs[level]){
            if let image = UIImage(named: "tick.png") {
                runCheckedBtn.setImage(image, for: [])
            }
        }else{
            flag = false
            if let image = UIImage(named: "tick-clicked.png") {
                runCheckedBtn.setImage(image, for: [])
            }
        }
        
        //라벨 바꾸기
        if(flag){
            
            let AttributedString = MakeAttributedString.init(InputString: "목표를 이루셨군요 축하드려요!!")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "목표")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "목표")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "축하")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "축하")
            self.resultLabel.attributedText = AttributedString.AttributedString

        }else{
            let AttributedString = MakeAttributedString.init(InputString: "목표가 얼마남지 않았어요!\n조금만 더 힘을 냅시다!!")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "힘")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "힘")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "목표")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "목표")
            self.resultLabel.attributedText = AttributedString.AttributedString
            resultLabel.attributedText = AttributedString.AttributedString
        }
    }
}

