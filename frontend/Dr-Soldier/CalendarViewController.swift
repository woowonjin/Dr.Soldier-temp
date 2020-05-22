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
    
    let DB = DataBaseAPI.init()
    let Quary = DataBaseQuery.init()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    var fillDefaultColorsArray : Array<Array<String>> = []
    var fillDefaultColorsDictionary = [String : Int ]()

    
    let SegmentedBarData = ["🟩휴가","🟥훈련","🟨외출","🟦파견", "⬜️삭제"]
    let SegmentedBarColor = [UIColor.green,UIColor.red,UIColor.yellow,UIColor.blue , UIColor.clear]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //네비게이션바 세팅
        self.navigationItem.hidesBackButton = true;
        self.navigationItem.leftBarButtonItem = nil;
        let navview = Variable_Functions.init()
        self.navigationItem.titleView = navview.navView
    
       
        //세그먼트바 세팅
        SegmentedControl.removeAllSegments()
        SegmentedBarData.map({ text in
           SegmentedControl.insertSegment(withTitle: text, at: SegmentedControl.numberOfSegments, animated: false)
        })
        SegmentedControl.selectedSegmentIndex = 0
        
        
        //DB에서 불러오기
        fillDefaultColorsArray = DB.query(statement: Quary.SelectStar(Tablename: "Calendar"), ColumnNumber: 2)
        fillDefaultColorsArray.map({ each in
            fillDefaultColorsDictionary.updateValue(Int(each[1])! , forKey: each[0])
        })
        print(fillDefaultColorsDictionary)
    
        //self.calendar.deselect(self.calendar.today!)
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "CELL")
        self.calendar.allowsMultipleSelection = true
        self.calendar.swipeToChooseGesture.isEnabled = true
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        self.calendar.appearance.borderRadius = 0
        self.calendar.appearance.borderRadius = 0
    
    }
    
    
    //날짜가 선택되어있을때
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let date_string = self.dateFormatter.string(from: date)
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
        fillDefaultColorsDictionary.updateValue(SegmentedControl.selectedSegmentIndex + 1 , forKey: date_string)
        //print(fillDefaultColorsDictionary)
        calendar.deselect(date)
        calendar.reloadData()
    }
     
    //기본색상
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        //print("언제실행되는가?")
        let key = self.dateFormatter.string(from: date)
        if let colorindex = fillDefaultColorsDictionary[key] {
            return SegmentedBarColor[colorindex-1]
        }else{
            return  UIColor.clear
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        
        
        let key = self.dateFormatter.string(from: date)
        if let colorindex = fillDefaultColorsDictionary[key] {
           return SegmentedBarColor[colorindex-1]
       }else{
           return  UIColor.clear
       }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return UIColor.black
    }
    
    
}
