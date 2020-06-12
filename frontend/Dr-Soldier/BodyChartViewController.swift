//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Charts

class BodyChartViewController: UIViewController,ChartViewDelegate,UITextViewDelegate,UITableViewDelegate, UITableViewDataSource {
 

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as! CustomBodychartCell
        cell.date = Data[indexPath.row][0]
        cell.heiht = Data[indexPath.row][1]
        cell.weight = Data[indexPath.row][2]
        let w = first_suso_cut(number: Float(cell.weight)!)
        let h = first_suso_cut(number: Float(cell.heiht)!)
        //cell.Label.textColor = UIColor.white
        cell.Label.font = UIFont.boldSystemFont(ofSize: 10)
        cell.Label.text = "\(cell.date): \(h)cm / \(w)kg"
        return cell
    }
  
    @IBOutlet weak var Height: UITextView!
    @IBOutlet weak var NowWeight: UITextView!
    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var Chart: LineChartView!
    @IBOutlet weak var Table: UITableView!
    @IBOutlet weak var Label: UILabel!
    
    
    var HeightTmpString : String = ""
    var NowWeightTmpString : String = ""
    
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var Data : Array<Array<String>> = []
    var Dates : Array<String> = []
    var Weights : Array<Double> = []
    var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
        
        //뷰 배경 설정
        self.view.backgroundColor = UIColor.systemGray3
        
        //테이블 뷰 설정
        self.Table.dataSource = self
        self.Table.delegate = self
        self.Table.rowHeight = UITableView.automaticDimension
        //self.Table.allowsSelection = false
        
        //버튼설정
        self.RecordButton.backgroundColor = UIColor.init(rgb:0x5AC18E)
        self.RecordButton.tintColor = UIColor.white
        self.RecordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        //텍스트뷰 설정
        self.Height.delegate = self
        self.NowWeight.delegate = self
        self.Height.font = UIFont.boldSystemFont(ofSize: 15)
        self.NowWeight.font = UIFont.boldSystemFont(ofSize: 15)
        initialize_textview()
        
        //데이터 업데이트
        update_data()
        self.axisFormatDelegate = self
        setupChart()
        
        

        
   }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if text == "\n" {
             textView.resignFirstResponder()
             return false
         }
         return true
     }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        textView.text = ""
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == Height{
            HeightTmpString = Height.text
            if let HeightFloat = Float(Height.text!){
                Height.text = " \(first_suso_cut(number: HeightFloat)) cm"
            }
            if HeightTmpString == ""{
                Height.textColor = UIColor.gray
                Height.text = "키"
            }
        }
        else if textView == NowWeight{
            NowWeightTmpString = NowWeight.text
            if let NowWeightFloat = Float(NowWeight.text!){
                NowWeight.text = " \(first_suso_cut(number: NowWeightFloat)) kg"
          }
          if NowWeightTmpString == ""{
              NowWeight.textColor = UIColor.gray
              NowWeight.text = "몸무게"
          }
        }
    }
    
    func initialize_textview(){
        Height.textColor = UIColor.gray
        Height.text = "키"
        Height.textAlignment = NSTextAlignment.center
        NowWeight.textColor = UIColor.gray
        NowWeight.text = "몸무게"
        NowWeight.textAlignment = NSTextAlignment.center
    }
    
    func first_suso_cut(number : Float) -> String{
        return String(format: "%.1f", number)
    }
    
    func update_label(){
        
    }
    
    
    func get_date(inputdatestring : String) -> String{
        var date = ""
        for i in inputdatestring{
            if i != "-"{
                date.append(i)
            }
        }
        return date
    }

    
    func update_data(){
        self.Data = DB.query(statement: "SELECT * from record order by checked_date;", ColumnNumber: 3)
        Dates.removeAll()
        Weights.removeAll()
        for each in Data{
            Dates.append(each[0])
            
            Weights.append( Double( Float(each[2])!) )
        }
        print("------------")
        print(Data,Dates,Weights)
        print("------------")
    }
    
    func setupChart(){

               //self.Chart.descriptionText = "Speed"
                //self.Chart.descriptionTextColor = UIColor.black
        self.Chart.gridBackgroundColor = UIColor.darkGray
        self.Chart.noDataText = "데이터가 없습니다"
        self.Chart.rightAxis.enabled = false
        self.Chart.drawGridBackgroundEnabled = false
        self.Chart.doubleTapToZoomEnabled = false
        self.Chart.xAxis.drawGridLinesEnabled = false
        self.Chart.xAxis.drawAxisLineEnabled = false
        self.Chart.rightAxis.drawGridLinesEnabled = false
        self.Chart.rightAxis.drawAxisLineEnabled = false
        self.Chart.leftAxis.drawGridLinesEnabled = false
        self.Chart.leftAxis.drawAxisLineEnabled = false
        self.Chart.xAxis.labelFont = UIFont.systemFont(ofSize: 5)
        self.Chart.backgroundColor = UIColor.white
        self.Chart.animate(yAxisDuration: 0.1)
        //self.Chart.xAxis.valueFormatter = XAxisValueFormatter as IAxisValueFormatter
        setChartData(xValsArr: self.Dates, yValsArr: self.Weights)
    }


    func setChartData(xValsArr: [String], yValsArr: [Double]) {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        yVals1.removeAll()
        for (index, item) in xValsArr.enumerated() {
            let Date = formatter.date(from: item)
            yVals1.append(ChartDataEntry.init(x: Date!.timeIntervalSince1970, y: yValsArr[index] ) )
            print(yVals1)
        }
        print(xValsArr,yValsArr)
        let set1: LineChartDataSet = LineChartDataSet(entries: yVals1, label: "First Set")
        
        //set설정
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5)) // our line's opacity is 50%
        set1.drawCirclesEnabled = false
        set1.lineWidth = 0.5
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.drawFilledEnabled = false
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true

        
        let LineChartData1 = LineChartData.init(dataSet: set1 as IChartDataSet )
        Chart.xAxis.valueFormatter = axisFormatDelegate
       //data.setValueTextColor(UIColor.whiteColor())

        //self.Chart.xAxis.valueFormatter = self
       //5 - finally set our data
        self.Chart.data = LineChartData1
        //Chart.xAxis.valueFormatter = axisFormatDelegate
        self.Chart.reloadInputViews()
    }
    
    @IBAction func RecordButtonTaped(_ sender: Any) {
        initialize_textview()
        if let Weightfloat = Float(NowWeightTmpString) , let Heightfloat = Float(HeightTmpString){
           
           //오늘날짜
           let today = Date()
           let format = DateFormatter()
           format.dateFormat = "yyyy-MM-dd"
           let today_string = format.string(from: today)
           let value = "'\(today_string)' , '\(first_suso_cut(number: Heightfloat) )', '\(first_suso_cut(number: Weightfloat))'"
           
           //디비입력
           if DB.insert(statement: Query.insert(Tablename: "Record", Values: value)){
                update_data()
                update_label()
                self.Table.reloadData()
                setChartData(xValsArr: self.Dates, yValsArr: self.Weights)
           }
       }else{
            self.Label.text = "잘못된 입력입니다. 다시 입력하여 주세요."
       }
    }
    
    @IBAction func Delete(_ sender: Any) {
        update_data()
        update_label()
        setChartData(xValsArr: self.Dates, yValsArr: self.Weights)
        //Chart.reloadInputViews()
        Table.reloadData()
    }
}

extension BodyChartViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let date = Date(timeIntervalSince1970: value)
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd"
           formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
           return formatter.string(from: date)
    }
}


class CustomBodychartCell : UITableViewCell {
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var date : String = ""
    var heiht : String = ""
    var weight : String = ""
    
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var DeleteButton: UIButton!
    
    @IBAction func Delete(_ sender: Any) {
        if DB.delete(statement: Query.Delete(Tablename: "Record", Condition: "checked_date = '\(date)' AND height = '\(heiht)' AND weight = '\(weight)'")){
           print("Success to delete record table")
        }else{
           print("fail to delete record table")
       }
    }
}
/*
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath) as! CustomBodychartCell
        cell.date = Data[indexPath.row][0]
        cell.heiht = Data[indexPath.row][1]
        cell.weight = Data[indexPath.row][2]
        let w = first_suso_cut(number: Float(cell.weight)!)
        let h = first_suso_cut(number: Float(cell.heiht)!)
        //cell.Label.textColor = UIColor.white
        cell.Label.font = UIFont.boldSystemFont(ofSize: 10)
        cell.Label.text = "\(cell.date): \(h)cm / \(w)kg"
        return cell
    }
    
    @IBOutlet weak var Height: UITextView!
    @IBOutlet weak var NowWeight: UITextView!
    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var Chart: LineChartView!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var Table: UITableView!
    
    var HeightTmpString : String = ""
    var NowWeightTmpString : String = ""
    
    let DB = DataBaseAPI.init()
    let Query = DataBaseQuery.init()
    var Data : Array<Array<String>> = []
    var Dates : Array<String> = []
    var Weights : Array<Double> = []
    var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
        
        //뷰 배경 설정
        self.view.backgroundColor = UIColor.systemGray3
        
        //테이블 뷰 설정
        self.Table.dataSource = self
        self.Table.delegate = self
        self.Table.rowHeight = UITableView.automaticDimension
        //self.Table.allowsSelection = false
        
        //버튼설정
        self.RecordButton.backgroundColor = UIColor.init(rgb:0x5AC18E)
        self.RecordButton.tintColor = UIColor.white
        self.RecordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        //텍스트뷰 설정
        self.Height.delegate = self
        self.NowWeight.delegate = self
        self.Height.font = UIFont.boldSystemFont(ofSize: 15)
        self.NowWeight.font = UIFont.boldSystemFont(ofSize: 15)
        initialize_textview()
        
        //데이터 업데이트
        update_data()
        setupChart()
   }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if text == "\n" {
             textView.resignFirstResponder()
             return false
         }
         return true
     }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        textView.text = ""
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == Height{
            HeightTmpString = Height.text
            if let HeightFloat = Float(Height.text!){
                Height.text = " \(first_suso_cut(number: HeightFloat)) cm"
            }
            if HeightTmpString == ""{
                Height.textColor = UIColor.gray
                Height.text = "키"
            }
        }
        else if textView == NowWeight{
            NowWeightTmpString = NowWeight.text
            if let NowWeightFloat = Float(NowWeight.text!){
                NowWeight.text = " \(first_suso_cut(number: NowWeightFloat)) kg"
          }
          if NowWeightTmpString == ""{
              NowWeight.textColor = UIColor.gray
              NowWeight.text = "몸무게"
          }
        }
    }
    
    func initialize_textview(){
        Height.textColor = UIColor.gray
        Height.text = "키"
        Height.textAlignment = NSTextAlignment.center
        NowWeight.textColor = UIColor.gray
        NowWeight.text = "몸무게"
        NowWeight.textAlignment = NSTextAlignment.center
    }
    
    func first_suso_cut(number : Float) -> String{
        return String(format: "%.1f", number)
    }
    
    func update_label(){
        
    }
    
    
    func get_date(inputdatestring : String) -> String{
        var date = ""
        for i in inputdatestring{
            if i != "-"{
                date.append(i)
            }
        }
        return date
    }

    
    func update_data(){
        self.Data = DB.query(statement: "SELECT * from record order by checked_date;", ColumnNumber: 3)
        Dates.removeAll()
        Weights.removeAll()
        for each in Data{
            Dates.append(each[0])
            
            Weights.append( Double( Float(each[2])!) )
        }
        print("------------")
        print(Data,Dates,Weights)
        print("------------")
    }
    
    func setupChart(){

               //self.Chart.descriptionText = "Speed"
                //self.Chart.descriptionTextColor = UIColor.black
        self.Chart.gridBackgroundColor = UIColor.darkGray
        self.Chart.noDataText = "데이터가 없습니다"
        self.Chart.rightAxis.enabled = false
        self.Chart.drawGridBackgroundEnabled = false
        self.Chart.doubleTapToZoomEnabled = false
        self.Chart.xAxis.drawGridLinesEnabled = false
        self.Chart.xAxis.drawAxisLineEnabled = false
        self.Chart.rightAxis.drawGridLinesEnabled = false
        self.Chart.rightAxis.drawAxisLineEnabled = false
        self.Chart.leftAxis.drawGridLinesEnabled = false
        self.Chart.leftAxis.drawAxisLineEnabled = false
        self.Chart.xAxis.labelPosition = .bottom
        self.Chart.backgroundColor = UIColor.white
        self.Chart.animate(yAxisDuration: 1.0)
        //self.Chart.xAxis.valueFormatter = XAxisValueFormatter as IAxisValueFormatter
        setChartData(xValsArr: self.Dates, yValsArr: self.Weights)
    }


    func setChartData(xValsArr: [String], yValsArr: [Double]) {
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        yVals1.removeAll()
        for (index, item) in xValsArr.enumerated() {
            let Date = formatter.date(from: item)
            yVals1.append(ChartDataEntry.init(x: Date!.timeIntervalSince1970, y: yValsArr[index] ) )
            print(yVals1)
        }
        print(xValsArr,yValsArr)
        let set1: LineChartDataSet = LineChartDataSet(entries: yVals1, label: "First Set")
        
        //set설정
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.red.withAlphaComponent(0.5)) // our line's opacity is 50%
        set1.drawCirclesEnabled = false
        set1.lineWidth = 0.5
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.red
        set1.drawFilledEnabled = true
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true

        
        let LineChartData1 = LineChartData.init(dataSet: set1 as IChartDataSet )
       //data.setValueTextColor(UIColor.whiteColor())

       //5 - finally set our data
        self.Chart.data = LineChartData1
        self.Chart.reloadInputViews()
    }
    
    @IBAction func RecordButtonTaped(_ sender: Any) {
        initialize_textview()
        if let Weightfloat = Float(NowWeightTmpString) , let Heightfloat = Float(HeightTmpString){
            
            //오늘날짜
            let today = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            let today_string = format.string(from: today)
            let value = "'\(today_string)' , '\(first_suso_cut(number: Heightfloat) )', '\(first_suso_cut(number: Weightfloat))'"
            
            //디비입력
            if DB.insert(statement: Query.insert(Tablename: "Record", Values: value)){
                update_data()
                update_label()
                self.Table.reloadData()
            }
        }else{
            
        }
        
    }
    
    @IBAction func Delete(_ sender: Any) {
        update_data()
        update_label()
        Chart.reloadInputViews()
        Table.reloadData()

    }
 */


class XAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        return formatter.string(from: date)
    }
}
