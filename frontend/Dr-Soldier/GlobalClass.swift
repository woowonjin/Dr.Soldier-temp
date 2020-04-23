//
//  GlobalClass.swift
//  Dr-Soldier
//
//  Created by leejungjae on 2020/04/23.
//  Copyright © 2020 LDH. All rights reserved.
//

import Foundation
import UIKit


class Variable_Functions{
    //네비게이션 바 만들기
    let navView = UIView()
    
    public init(){
        let label = UILabel()
        label.text = "닥터 솔저"
        label.font = UIFont(name:"HelveticaNeue-Bold", size: 20.0)
        label.textColor = UIColor.white
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = NSTextAlignment.center
        let image = UIImageView()
        image.image = UIImage(named: "doctor3.png")
        let imageAspect = image.image!.size.width/image.image!.size.height
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        navView.addSubview(label)
        navView.addSubview(image)
    }
}
