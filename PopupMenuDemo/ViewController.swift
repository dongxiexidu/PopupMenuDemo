//
//  ViewController.swift
//  PopupMenuDemo
//
//  Created by fashion on 2017/10/16.
//  Copyright © 2017年 shangZhu. All rights reserved.
//  简书:http://www.jianshu.com/u/6f76b136c31e

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    var popupMenu : PopupMenu?
    let TITLES = ["修改", "删除", "扫一扫","付款"]
    let ICONS = ["motify","delete","saoyisao","pay"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func topLeftBtnPopupMenueClick(_ sender: Any) {
     
        PopupMenu.showRelyOnView(view: sender as! UIView, titles: TITLES, icons: ICONS, menuWidth: 120, didSelectRow: { (index, value, popupMenu) in
            print("索引是: \(index)值是: \(value)")
        }) { (popupMenu) in
            popupMenu.backColor = UIColor.lightGray
            popupMenu.separatorColor = UIColor.white
            popupMenu.priorityDirection = PopupMenuPriorityDirection.none
            popupMenu.borderWidth = 1
            popupMenu.borderColor = UIColor.red
            popupMenu.rectCorner = [.bottomRight,.bottomLeft]
        }
    }
    @IBAction func topRightBtnPopupMenueClick(_ sender: Any) {
        
        PopupMenu.showRelyOnView(view: sender as! UIView, titles: TITLES, icons: ICONS, menuWidth: 120, delegate: self) { (popupMenu) in
            popupMenu.priorityDirection = PopupMenuPriorityDirection.none
            popupMenu.borderWidth = 1
            popupMenu.borderColor = UIColor.red
           // popupMenu.rectCorner = [.bottomRight,.bottomLeft]
        }
    }
    
    
    @IBAction func bottomLeftBtnPopupMenueClick(_ sender: Any) {
     
        // 不推荐使用
        let popupMenu = PopupMenu.showRelyOnView(view: sender as! UIView, titles: TITLES, icons: ICONS, menuWidth: 120, delegate: self)
        popupMenu.tag = 0
//        popupMenu.borderWidth = 1
//        popupMenu.borderColor = UIColor.red
        popupMenu.rectCorner = [.bottomRight,.bottomLeft]
        popupMenu.updateUI()
        
    }
    
    @IBAction func bottomRightBtnPopupMenueClick(_ sender: Any) {
        
        PopupMenu.showRelyOnView(view: sender as! UIView, titles: ["111","222","333","444","555","666","777","888"], icons: nil, menuWidth: 100, didSelectRow: { (index, value, _) in
            
            print("索引是: \(index)值是: \(value)")
        }) { (popupMenu) in // 无需设置delegate
            popupMenu.borderWidth = 1
            popupMenu.borderColor = UIColor.red
           // popupMenu.rectCorner = [.topLeft,.bottomLeft]
        }
        
    }
    @IBAction func onTestBtnClick(_ sender: Any) {
        
        PopupMenu.showRelyOnView(view: sender as! UIView, titles: ["111","222","333","444","555","666","777","888"], icons: nil, menuWidth: 100, didSelectRow: { (index, value, _) in
            
            print("索引是: \(index)值是: \(value)")
        }) { (popupMenu) in // 无需设置delegate
            
            popupMenu.priorityDirection = PopupMenuPriorityDirection.left
            popupMenu.borderWidth = 1
            popupMenu.borderColor = UIColor.red
            popupMenu.rectCorner = [.topLeft,.bottomLeft]
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = (touches as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self.view)
        
        popupMenu = PopupMenu.showAtPoint(point: point, titles: TITLES, icons: nil, menuWidth: 110, delegate: self, otherSettings: { (popupMenu) in
            popupMenu.dismissOnSelected = false
            popupMenu.isShowShadow = true
            popupMenu.offset = 10
            popupMenu.type = PopupMenuType.dark
            popupMenu.rectCorner = UIRectCorner.allCorners
            popupMenu.priorityDirection = .none
        })
    }
}

extension ViewController : PopupMenuDelegate{
    
    func popupMenuDidSelected(index: NSInteger, popupMenu: PopupMenu) {
        if popupMenu.tag == 111 {
            print(["111","222","333","444","555","666","777","888"][index])
        }else{
            print(TITLES[index])
        }
    }
}

extension ViewController : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
      popupMenu = PopupMenu.showRelyOnView(view: textField, titles: ["密码必须为数字、大写字母、小写字母和特殊字符中至少三种的组合，长度不少于8且不大于20"], icons: nil, menuWidth: textField.bounds.width, delegate: self) { (popupMenu) in
                popupMenu.delegate = self
                popupMenu.showMaskView = false
                popupMenu.priorityDirection = PopupMenuPriorityDirection.bottom
                popupMenu.maxVisibleCount = 1
                popupMenu.borderWidth = 1
                popupMenu.fontSize = 12
                popupMenu.dismissOnTouchOutside = true
                popupMenu.dismissOnSelected = false
                popupMenu.borderColor = UIColor.brown
                popupMenu.textColor = UIColor.brown
                popupMenu.itemHeight = 60
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        popupMenu?.dismiss()
        return true
    }
}

