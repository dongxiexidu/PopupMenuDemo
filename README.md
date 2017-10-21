# PopupMenu

![](https://img.shields.io/travis/USER/REPO.svg) ![](https://img.shields.io/github/license/mashape/apistatus.svg)

### Presentation mode for your iOS app

PopupMenu is a small library (four class) meant for presentations from iOS devices that shows a small menu you can Highly customized.


### Usage

#### example one use delegate
```objc

    var popupMenu : PopupMenu?
    let TITLES = ["修改", "删除", "扫一扫","付款"]
    let ICONS = ["motify","delete","saoyisao","pay"]

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
    
    extension ViewController : PopupMenuDelegate{
    
    func popupMenuDidSelected(index: NSInteger, popupMenu: PopupMenu) {
        if popupMenu.tag == 111 {
            print(["111","222","333","444","555","666","777","888"][index])
        }else{
            print(TITLES[index])
        }
    }
}
```

#### example two use block

```objc
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
```

![](demo.gif)

[Objective-C version](https://github.com/lyb5834/YBPopupMenu)
