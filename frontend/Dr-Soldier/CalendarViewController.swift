//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//



import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var SegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var Label: UILabel!
    
    
    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    fileprivate lazy var dateFormatterForInt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    
    
    
    var fillDefaultColorsArray : Array<Array<String>> = []
    var fillDefaultColorsDictionary = [String : Int ]()

    
    let SegmentedBarData = ["🟩휴가","🟥훈련","🟨외출","🟦파견", "⬜️삭제"]
    let SegmentedBarColor = [UIColor.init(rgb:0x5AC18E),UIColor.init(rgb: 0xff7373) , UIColor.init(rgb: 0xe8a87c) ,UIColor.init(rgb: 0x22A39F), UIColor.clear]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //네비게이션바 세팅
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.leftBarButtonItem = nil;
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
    
       
        //세그먼트바 세팅
        SegmentedControl.removeAllSegments()
        let _ = SegmentedBarData.map({ text in
           SegmentedControl.insertSegment(withTitle: text, at: SegmentedControl.numberOfSegments, animated: false)
        })
        SegmentedControl.selectedSegmentIndex = 0
        
        
        //DB에서 불러오기
        fillDefaultColorsArray = DB.query(statement: Quary.SelectStar(Tablename: "Calendar"), ColumnNumber: 2)
        let _ = fillDefaultColorsArray.map({ each in
            fillDefaultColorsDictionary.updateValue(Int(each[1])! , forKey: each[0])
        })
        self.calendar.appearance.borderRadius = 0
        self.calendar.appearance.todayColor = UIColor.clear
        self.calendar.appearance.todaySelectionColor = UIColor.clear
        self.calendar.appearance.titleTodayColor = UIColor.black
        self.calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
        self.calendar.dataSource = self
        self.calendar.delegate = self
        Label.numberOfLines = 2
        updateLabel()
      
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date as Date, at: position)
        let key = self.dateFormatter.string(from: date)
        if let colorindex = fillDefaultColorsDictionary[key] {
            cell.backgroundColor = SegmentedBarColor[colorindex-1]
        }else{
            cell.backgroundColor = UIColor.clear
        }
        if date == self.calendar.today!{
            cell.layer.borderColor = SegmentedBarColor[0].cgColor
            cell.layer.borderWidth = 1.0
        }
        return cell
    }
    
    //날짜가 선택되어있을때
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let date_string = self.dateFormatter.string(from: date)
        self.calendar.currentPage = date
        //삭제
        if self.SegmentedControl.selectedSegmentIndex == 4 && fillDefaultColorsDictionary[date_string] != nil {
            if (DB.delete(statement: Quary.Delete(Tablename: "Calendar", Condition: "marked_date = " + "'\(date_string)'"))){
                print("delete success at calander")
            }
        }else{
            //기존 존재한다면 삭제하고 삽입한다.
            if (DB.delete(statement: Quary.Delete(Tablename: "Calendar", Condition: "marked_date = " + "'\(date_string)'"))){
                print("delete success at calander before insert")
            }
            if (DB.insert(statement: Quary.insert(Tablename: "Calendar", Values: " '\(date_string)', \(SegmentedControl.selectedSegmentIndex + 1)" ))){
                print("insert success at calander")
            }
        }
        self.calendar.deselect(date)
        
       
        
        if self.SegmentedControl.selectedSegmentIndex == 4{
            fillDefaultColorsArray = fillDefaultColorsArray.filter { (arr) -> Bool in
                if arr[0] == date_string{
                    return false
                }else{
                    return true
                }
            }
        } else{

            fillDefaultColorsArray.append([date_string, "\(SegmentedControl.selectedSegmentIndex + 1)"])
        }
        fillDefaultColorsDictionary.updateValue(SegmentedControl.selectedSegmentIndex + 1 , forKey: date_string)
        self.calendar.cell(for: date, at: monthPosition)?.backgroundColor = SegmentedBarColor[SegmentedControl.selectedSegmentIndex]
        updateLabel()
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    
    func updateLabel(){
        var 휴가 : Int = 99999
        var 외출 : Int = 99999
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        
        //오늘 날짜
        let today_string = formatter.string(from: self.calendar.today!)
        
        for each in fillDefaultColorsArray {
            
            if each[1] == "2" || each[1] == "4" || each[1] == "5" {
                continue
            }
            
            let 차이 = daysBetween(start: self.calendar.today! , end: formatter.date(from: each[0])!)
            if 차이 < 0 {
                continue
            }
            
            if each[1] == "1" && 차이 < 휴가 && each[0] != today_string {
                휴가 = 차이
            }
            if each[1] == "3" && 차이 < 외출 && each[0] != today_string{
                외출 = 차이
            }
        }
        var 휴가문구 : String = ""
        var 외출문구 : String = ""
        
        if 휴가 == 99999 {
            휴가문구 = "다음 휴가를 설정해봐요!"
        }else if 휴가 == 0 {
            휴가문구 = "오늘 휴가시군요!"
        }else {
            휴가문구 = "다음 휴가까지 \(휴가)일 남았어요."
        }
        
        if 외출 == 99999 {
            외출문구 = "다음 외출를 설정해봐요!"
        }else if 외출 == 0 {
            외출문구 = "오늘 외출시군요!"
        }else {
            외출문구 = "다음 외출까지 \(외출)일 남았어요."
        }
        Label.text = 휴가문구 + "\n" + 외출문구
        Label.font = UIFont.systemFont(ofSize: 15)
        let attributedStr = NSMutableAttributedString(string: Label.text!)
        attributedStr.addAttribute(.foregroundColor, value: SegmentedBarColor[0] , range: (Label.text! as NSString).range(of: "휴가"))
        attributedStr.addAttribute(.foregroundColor, value: SegmentedBarColor[2] , range: (Label.text! as NSString).range(of: "외출"))
        
        attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),
                value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "휴가"))
        attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),
                       value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "외출"))
        Label.attributedText = attributedStr
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")
       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
