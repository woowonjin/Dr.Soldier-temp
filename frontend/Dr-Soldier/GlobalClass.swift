//
//  GlobalClass.swift
//  Dr-Soldier
//
//  Created by leejungjae on 2020/04/23.
//  Copyright © 2020 LDH. All rights reserved.
//

import Foundation
import UIKit


class MakeViewWithNavigationBar{
    //네비게이션 바 만들기
    let navView = UIView()
    public init( InputString : String){
        let label = UILabel()
        label.text = InputString
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        label.textColor = UIColor.white
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        navView.addSubview(label)
    }
    
    public init( InputString : String , InputImage : UIImage){
        let label = UILabel()
        label.text = InputString
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        label.textColor = UIColor.white
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        let Image = UIImageView()
        Image.image = InputImage
        let ImageAspect = Image.image!.size.width/Image.image!.size.height
        Image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*ImageAspect, y: label.frame.origin.y, width: label.frame.size.height*ImageAspect, height: label.frame.size.height)
        Image.contentMode = UIView.ContentMode.scaleAspectFit
        navView.addSubview(label)
        navView.addSubview(Image)
    }
}

class MakeAttributedString{
    var AttributedString = NSMutableAttributedString()
    var InputString : String = ""
    
    public init(InputString : String){
        self.AttributedString = NSMutableAttributedString(string: InputString)
        self.InputString = InputString
    }
    
    public func AddColorAttribute(Color : UIColor, WhichPart : String){
        self.AttributedString.addAttribute(.foregroundColor, value: Color , range: (self.InputString as NSString).range(of: WhichPart))
    }
    
    public func AddFontAttribute(Font : UIFont , WhichPart : String){
        self.AttributedString.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),value: Font, range: (self.InputString as NSString).range(of: WhichPart))
    }
}
