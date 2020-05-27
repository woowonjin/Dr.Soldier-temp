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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let navview = Variable_Functions.init()
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
        Label.text = "계산은 닥터가 할게요. \n 입력만 해주세요!"
        let attributedStr = NSMutableAttributedString(string: Label.text!)
        attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb:0x5AC18E) , range: (Label.text! as NSString).range(of: "닥터"))
        
        attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "닥터"))
        attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb:0xe8a87c) , range: (Label.text! as NSString).range(of: "입력"))
        
        attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "입력"))
        Label.attributedText = attributedStr
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
    
    func calWerfare(money : Float64, ratio : Float64, Month:Float64) -> Int{
        let monthratio = (ratio/100.0)*(1.0/12.0) + 1
        var total = 0.0
        for _ in 1...Int(Month) {
            total = (total + money) * monthratio
        }
        return Int(total)
    }
    
    func makemoneyform(Money : Int) -> String{
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
    
    
    @IBAction func Calculate(_ sender: Any) {
        let Moneytext = Money.text
        let Ratiotext = Ratio.text
        let Monthtext = Month.text
        initailize_textview()
        if let Moneyfloat = Float64(Moneytext!) , let Ratiofloat = Float64(Ratiotext!) , let Monthfloat = Float64(Monthtext!){
            var total : Int = 0
            if SegmentBarControl.selectedSegmentIndex == 0{
               total = calWerfare(money: Moneyfloat, ratio: Ratiofloat, Month: Monthfloat)
           }else{
                total = Int(Monthfloat * Moneyfloat * (1.0 + Ratiofloat))
           }
            let totalstring = makemoneyform(Money: total)
            let Moneystring = makemoneyform(Money: Int(Moneyfloat))
            
            Label.text = "매달 \(Moneystring)씩 \(Int(Monthfloat))개월 동안\n\(Ratiofloat)의 이율로 계산하였을 때\n만기시 \(totalstring)원을 받으실 수 있어요!"
            let attributedStr = NSMutableAttributedString(string: Label.text!)
            
            attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb:0xe8a87c) , range: (Label.text! as NSString).range(of: "\(Moneystring)"))
            attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "\(Moneystring)"))
            
            attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb:0xe8a87c) , range: (Label.text! as NSString).range(of: "\(Int(Monthfloat))"))
            attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "\(Int(Monthfloat))"))
            
            attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb:0xe8a87c) , range: (Label.text! as NSString).range(of: "\(Ratiofloat)"))
            attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "\(Ratiofloat)"))
            
            
            attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb: 0x5AC18E) , range: (Label.text! as NSString).range(of: "\(totalstring)"))
            attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "\(totalstring)"))
            Label.attributedText = attributedStr
            
        } else {
            Label.text = "입력이 잘못되었네요! \n 숫자로만 입력해주세요."
            let attributedStr = NSMutableAttributedString(string: Label.text!)
            attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb: 0xe8a87c) , range: (Label.text! as NSString).range(of: "입력"))
            attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "입력"))
            attributedStr.addAttribute(.foregroundColor, value:UIColor.init(rgb:0x5AC18E) , range: (Label.text! as NSString).range(of: "숫자"))
            attributedStr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: UIFont.boldSystemFont(ofSize: 22), range: (Label.text! as NSString).range(of: "숫자"))
            Label.attributedText = attributedStr
        }
        
        
    
            
    }
    
}

