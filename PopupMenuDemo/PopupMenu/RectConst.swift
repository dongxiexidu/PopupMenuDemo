//
//  RectConst.swift
//  PopupMenuDemo
//
//  Created by fashion on 2017/10/16.
//  Copyright © 2017年 shangZhu. All rights reserved.
//  简书:http://www.jianshu.com/u/6f76b136c31e

import UIKit

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let mainWindow = UIApplication.shared.keyWindow!

public func rectWidth(_ rect : CGRect)-> CGFloat {
    return rect.size.width
}

public func rectHeight(_ rect : CGRect)-> CGFloat {
    return rect.size.height
}

public func rectX(_ rect : CGRect)-> CGFloat {
    return rect.origin.x
}

public func rectY(_ rect : CGRect)-> CGFloat {
    return rect.origin.y
}

public func rectTop(_ rect : CGRect)-> CGFloat {
    return rect.origin.y
}

public func rectBottom(_ rect : CGRect)-> CGFloat {
    return rect.origin.y + rect.size.height
}

public func rectLeft(_ rect : CGRect)-> CGFloat {
    return rect.origin.x
}

public func rectRight(_ rect : CGRect)-> CGFloat {
    return rect.origin.x + rect.size.width
}
