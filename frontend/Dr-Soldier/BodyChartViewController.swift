//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit
import Charts

class BodyChartViewController: UIViewController,ChartViewDelegate,UITextViewDelegate,UITableViewDelegate, UITableViewDataSource , IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value<0 || Int(value) >=  Data.count{
            return ""
        }else{
            return self.Data[Int(value)][0]
        }
    }
 

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
        cell.Label.font = UIFont.boldSystemFont(ofSize: 15)
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
    var Index : Array<Int> = []
    var Weights : Array<Double> = []
    var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let navview = MakeViewWithNavigationBar.init(InputString: "체중기록")
        self.navigationItem.titleView = navview.navView
        
        //뷰 배경 설정
        self.view.backgroundColor = UIColor.systemGray5
        
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
        
        //label 설정
        Label.numberOfLines = 0
        Label.lineBreakMode = NSLineBreakMode.byWordWrapping;
        Label.sizeToFit()
        Label.textAlignment = .center
        Label.font = UIFont.boldSystemFont(ofSize: 15)
        
        
        //데이터 업데이트
        self.axisFormatDelegate = self
        update_data()
        setupChart()
        
   }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         if text == "\n" {
            if textView == NowWeight{
                 RecordButtonTapFuntion()
            }
             textView.resignFirstResponder()
             return false
         }
         return true
     }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        textView.text = ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == Height{
            HeightTmpString = Height.text
        }
        else if textView == NowWeight{
            NowWeightTmpString = NowWeight.text
         }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == Height{
            //HeightTmpString = Height.text
            if let HeightFloat = Float(Height.text!){
                Height.text = " \(first_suso_cut(number: HeightFloat)) cm"
            }
            if HeightTmpString == ""{
                Height.textColor = UIColor.gray
                Height.text = "키"
            }
            self.NowWeight.becomeFirstResponder()
        }
        else if textView == NowWeight{
            //NowWeightTmpString = NowWeight.text
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
        if self.Data.count == 0 {
    
            let AttributedString = MakeAttributedString.init(InputString: "닥터가 관리해드릴게요. \n 기록해보세요!")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "닥터")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "닥터")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "기록")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "기록")
            self.Label.attributedText = AttributedString.AttributedString
        }
        else if self.Data.count == 1 {
            
            let AttributedString = MakeAttributedString.init(InputString: "최근 측정 몸무게는 \n \(Data[0][2])kg 입니다.")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "몸무게")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "몸무게")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(Data[0][2])kg")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(Data[0][2])kg")
            self.Label.attributedText = AttributedString.AttributedString
            
        }else{
            let Inteval = Double(Float(Data[Data.count-1][2])!) - Double(Float(Data[Data.count-2][2])!)
            if Inteval > 0{
                let AttributedString = MakeAttributedString.init(InputString: "몸무게가 \(Inteval)kg\n증가 하였네요.")
                AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "증가")
                AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "증가")
                AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(Inteval)kg")
                AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(Inteval)kg")
                self.Label.attributedText = AttributedString.AttributedString
            }else if Inteval == 0{
                let AttributedString = MakeAttributedString.init(InputString: "저번 기록과 \n 몸무게가 동일하네요.")
                AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "기록")
                AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "기록")
                AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "동일")
                AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "동일")
                self.Label.attributedText = AttributedString.AttributedString
            }else{
                let AttributedString = MakeAttributedString.init(InputString: "몸무게가 \(-Inteval)kg \n 감소 하였네요.")
                AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "감소")
                AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "감소")
                AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(-Inteval)kg")
                AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(-Inteval)kg")
                self.Label.attributedText = AttributedString.AttributedString
            }
        }
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
        Index.removeAll()
        Weights.removeAll()
        Index.append(-1)
        for (index,each) in self.Data.enumerated(){
            Index.append(index)
            Weights.append( Double( Float(each[2])!) )
        }
        Index.append(Data.count)
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
        self.Chart.xAxis.drawAxisLineEnabled = true
        self.Chart.xAxis.labelPosition = .bottom
        self.Chart.rightAxis.drawGridLinesEnabled = false
        self.Chart.rightAxis.drawAxisLineEnabled = false
        self.Chart.leftAxis.drawGridLinesEnabled = true
        self.Chart.leftAxis.drawAxisLineEnabled = true
        //self.axisFormatDelegate.
        self.Chart.rightAxis.axisMinimum = 0.0
        self.Chart.leftAxis.axisMinimum = 0.0
        self.Chart.leftAxis.axisMaximum = 120.0
        self.Chart.borderColor = UIColor.black
        self.Chart.borderLineWidth = 1
        self.Chart.xAxis.labelFont = UIFont.boldSystemFont(ofSize: 5)
        self.Chart.xAxis.labelTextColor = UIColor.black
        self.Chart.backgroundColor = UIColor.white
        self.Chart.animate(yAxisDuration: 0.1)
        self.Chart.animate(xAxisDuration: 0.1)
        //self.Chart.borderLineWidth = 10
        //self.Chart.xAxis.valueFormatter = XAxisValueFormatter as IAxisValueFormatter
        setChartData(xValsArr: self.Index, yValsArr: self.Weights)
    }


    func setChartData(xValsArr: [Int], yValsArr: [Double]) {
        print(xValsArr,yValsArr)
        //self.Chart.xAxis.axisMaxLabels = self.Index.count
        /*
        if self.Index.count == 0 || self.Index.count == 1{
            self.Chart.xAxis.labelCount = 2
        }else{
            self.Chart.xAxis.labelCount = self.Index.count
        }
 */
        print()
        self.Chart.xAxis.labelCount = self.Index.count - 2
        self.Chart.xAxis.axisMaximum = Double(self.Index.count) - 2
        self.Chart.xAxis.axisMinimum = -1
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        yVals1.removeAll()
        for i in xValsArr{
            //let Date = formatter.date(from: item)
            if i == -1 || i == Data.count{
                continue
            }
            yVals1.append(ChartDataEntry.init(x: Double(i), y: yValsArr[i]))
            print(yVals1)
        }
        //print(xValsArr,yValsArr)
        let set1: LineChartDataSet = LineChartDataSet(entries: yVals1, label: "몸무게")
        
        //set설정
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(UIColor.init(rgb:0xe8a87c)) // our line's opacity is 50%
        set1.drawCirclesEnabled = true
        set1.lineWidth = 1
        set1.circleRadius = 2.0 // the radius of the node circle
        set1.setCircleColor(UIColor.init(rgb:0xe8a87c))
        set1.fillAlpha = 100 / 255.0
        set1.fillColor = UIColor.init(rgb:0xe8a87c)
        set1.drawFilledEnabled = true
        set1.fillColor = UIColor.init(rgb:0xe8a87c)
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true

        
        let LineChartData1 = LineChartData.init(dataSet: set1 as IChartDataSet )
        Chart.xAxis.valueFormatter = axisFormatDelegate
        self.Chart.data = LineChartData1
        self.Chart.reloadInputViews()
        self.Chart.animate(xAxisDuration: 0.1)
        
        update_label()
    }
    
    func RecordButtonTapFuntion(){
         initialize_textview()
         print(NowWeightTmpString,HeightTmpString)
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
                 self.Table.reloadData()
                 setChartData(xValsArr: self.Index, yValsArr: self.Weights)
            }
        }else{
             self.Label.text = "잘못된 입력입니다. 다시 입력하여 주세요."
        }
    }
    
    @IBAction func RecordButtonTaped(_ sender: Any) {
       RecordButtonTapFuntion()
    }
    
    @IBAction func Delete(_ sender: Any) {
        update_data()
        setChartData(xValsArr: self.Index, yValsArr: self.Weights)
        //Chart.reloadInputViews()
        Table.reloadData()
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
