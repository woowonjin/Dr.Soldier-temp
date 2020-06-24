//
//  ViewController.swift
//  Dr-Soldier
//
//  Created by LDH on 2020/04/21.
//  Copyright © 2020 LDH. All rights reserved.
//

import UIKit

class FinanceViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var Money: UITextView!
    @IBOutlet weak var Month: UITextView!
    @IBOutlet weak var Ratio: UITextView!
    @IBOutlet weak var SegmentBarControl: UISegmentedControl!
    @IBOutlet weak var Button: UIButton!
    @IBOutlet weak var Label: UILabel!
    
    var Moneytmpstring : String = ""
    var Monthtmpstring : String = ""
    var Ratiotmpstring : String = ""
    
    var activeTextView = UITextView.init()
    var num = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let navview = MakeViewWithNavigationBar.init(InputString: " Finance", InputImage: UIImage(named: "gold")!)
        self.navigationItem.titleView = navview.navView
        
        //텍스트뷰 설정
        Money.delegate = self
        Ratio.delegate = self
        Month.delegate = self
        
        //세그먼트바 설정
        SegmentBarControl.removeAllSegments()
        SegmentBarControl.insertSegment(withTitle: "복리", at: 0, animated: false)
        SegmentBarControl.insertSegment(withTitle: "단리", at: 1, animated: false)
        SegmentBarControl.selectedSegmentIndex = 0
        SegmentBarControl.selectedSegmentTintColor = UIColor.init(rgb:0x5AC18E)
        SegmentBarControl.backgroundColor = UIColor.white
        
        
        //배경색 설정
        self.view.backgroundColor = UIColor.systemGray5
        
        //버튼설정
        self.Button.backgroundColor = UIColor.init(rgb:0x5AC18E)
        self.Button.tintColor = UIColor.white
        self.Button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
       
        //텍스트뷰 초기화
        Money.font = UIFont.boldSystemFont(ofSize: 20)
        Ratio.font = UIFont.boldSystemFont(ofSize: 17)
        Month.font = UIFont.boldSystemFont(ofSize: 17)
        initailize_textview()
        
        //Label설정
        Label.numberOfLines = 0
        Label.lineBreakMode = NSLineBreakMode.byWordWrapping;
        Label.sizeToFit()
        Label.font = UIFont.boldSystemFont(ofSize: 15)
        let AttributedString = MakeAttributedString.init(InputString: "계산은 닥터가 할게요. \n 입력만 해주세요!")
        AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "닥터")
        AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "닥터")
        AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "입력")
        AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "입력")
        self.Label.attributedText = AttributedString.AttributedString
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView == self.Ratio{
                CalculateFunction()
            }
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        textView.text = ""
        self.activeTextView = textView
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.Money{
            Moneytmpstring = Money.text
        }
        if textView == self.Month{
            Monthtmpstring = Month.text
        }
        if textView == self.Ratio{
            Ratiotmpstring = Ratio.text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
       // print(textView.accessibilityIdentifier!)
        if textView == self.Money{
            Moneytmpstring = Money.text
            if let MoneyInt = Int64(Money.text!){
                 Money.text =  makemoneyform(Money:MoneyInt) + "원"
            }
            if Moneytmpstring == ""{
                Money.textColor = UIColor.gray
                Money.text = "월적립액(원)"
                Money.textAlignment = NSTextAlignment.center
            }
            self.Month.becomeFirstResponder()
        }
        if textView == self.Month{
            Monthtmpstring = Month.text
            if let MonthInt = Int64(Month.text!){
                 Month.text =  makemoneyform(Money:MonthInt) + "개월"
            }
            if Monthtmpstring == ""{
                Month.textColor = UIColor.gray
                Month.text = "적금기간(개월)"
                Month.textAlignment = NSTextAlignment.center
            }
            self.Ratio.becomeFirstResponder()
        }
        if textView == self.Ratio{
            Ratiotmpstring = Ratio.text
            if let RatioInt = Int64(Ratio.text!){
                 Ratio.text =  makemoneyform(Money:RatioInt) + "%"
            }
            if Ratiotmpstring == ""{
                Ratio.textColor = UIColor.gray
                Ratio.text = "이율"
                Ratio.textAlignment = NSTextAlignment.center
            }
        }
    }
    
    func initailize_textview(){
        Money.textColor = UIColor.gray
        Money.text = "월적립액(원)"
        Money.textAlignment = NSTextAlignment.center
        Ratio.textColor = UIColor.gray
        Ratio.text = "이율"
        Ratio.textAlignment = NSTextAlignment.center
        Month.textColor = UIColor.gray
        Month.text = "적금기간(개월)"
        Month.textAlignment = NSTextAlignment.center
    }
    
    func calWerfare(money : Float64, ratio : Float64, Month:Float64) -> Int64{
        let monthratio = (ratio/100.0)*(1.0/12.0) + 1
        var total = 0.0
        for _ in 1...Int(Month) {
            total = (total + money) * monthratio
        }
        return Int64(total)
    }
    
    func makemoneyform(Money : Int64) -> String{
        var Moneystring = "\(Money)"
        let count = Moneystring.count
        var now = 0
        for i in 0 ... count-1 {
            now = now + 1
            if now == 3 {
                now = 0
                if count-i-1 != 0 {
                    let index = Moneystring.index(Moneystring.startIndex, offsetBy: count - i-1)
                    Moneystring.insert(contentsOf: ",", at: index)
                }
            }
        }
        return Moneystring
    }
    
    func CalculateFunction(){
        let Moneytext = Moneytmpstring
        let Ratiotext = Ratiotmpstring
        let Monthtext = Monthtmpstring
        print(Moneytext,Ratiotext,Moneytext)
        initailize_textview()
        if let Moneyfloat = Float64(Moneytext) , let Ratiofloat = Float64(Ratiotext) , let Monthfloat = Float64(Monthtext){
            var total : Int64 = 0
            if SegmentBarControl.selectedSegmentIndex == 0{
               total = calWerfare(money: Moneyfloat, ratio: Ratiofloat, Month: Monthfloat)
           }else{
                total = Int64(Monthfloat * Moneyfloat * (1.0 + Ratiofloat))
           }
            let totalstring = makemoneyform(Money: total)
            let Moneystring = makemoneyform(Money: Int64(Moneyfloat))
            
            let AttributedString = MakeAttributedString.init(InputString:"매달 \(Moneystring)씩 \(Int(Monthfloat))개월 동안\n\(Ratiofloat)의 이율로 계산하였을 때\n만기시 \(totalstring)원을 받으실 수 있어요!")
            
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(Moneystring)")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(Moneystring)")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(Int(Monthfloat))")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(Int(Monthfloat))")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "\(Ratiofloat)")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(Ratiofloat)")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "\(totalstring)")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "\(totalstring)")
            self.Label.attributedText = AttributedString.AttributedString
            
        } else {
            
            let AttributedString = MakeAttributedString.init(InputString:"입력이 잘못되었네요! \n 숫자로만 입력해주세요.")
            
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0xe8a87c), WhichPart: "입력")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "입력")
            AttributedString.AddColorAttribute(Color: UIColor.init(rgb:0x5AC18E), WhichPart: "숫자")
            AttributedString.AddFontAttribute(Font: UIFont.boldSystemFont(ofSize: 22), WhichPart: "숫자")
            self.Label.attributedText = AttributedString.AttributedString
        }
    }
    
    
    @IBAction func Calculate(_ sender: Any) {
        CalculateFunction()
        self.Money.resignFirstResponder()
        self.Month.resignFirstResponder()
        self.Ratio.resignFirstResponder()
    }
}

