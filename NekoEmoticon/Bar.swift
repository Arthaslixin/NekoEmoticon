//
//  Bar.swift
//  NekoEmoticon
//
//  Created by arthas on 17/2/4.
//  Copyright (c) 2017年 arthas. All rights reserved.
//

import Cocoa
import ApplicationServices

class NekoBar: NSObject
{
    class var instance: NekoBar
    {
        struct Singleton {
            static let instance = NekoBar()
        }
        return Singleton.instance
    }
    
    var item: NSStatusItem? = nil;
    var icon: NSImage? = nil;
    var iconBlink: NSImage? = nil;
    
    override init()
    {
        super.init()
        
        let NSSquareStatusItemLength:CGFloat = -2
        
        let bar = NSStatusBar.system()
        let item = bar.statusItem(withLength: NSSquareStatusItemLength)
        
        icon = NSImage(named: "statusbar-icon")
        iconBlink = NSImage(named: "statusbar-icon-blink")
        
//        icon?.setTemplate(true)
//        iconBlink?.setTemplate(true)
        
        item.button?.image = icon
        item.button?.alternateImage = NSImage(named: "statusbar-icon-mousedown")
        self.item = item;
        
        beginBlinkAnim()
    }
    
    // blink animation
    
    func beginBlinkAnim()
    {
        let waiting = 2 + arc4random() % 4
        Timer.scheduledTimer(timeInterval: TimeInterval(waiting), target: self, selector: #selector(NekoBar.anim_blink(_:)), userInfo: nil, repeats: false)
    }
    
    func anim_blink(_ sender: AnyObject)
    {
        item?.button?.image = iconBlink
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(NekoBar.anim_blink_open(_:)), userInfo: nil, repeats: false)
    }
    
    func anim_blink_open(_ sender: AnyObject)
    {
        item?.button?.image = icon
        beginBlinkAnim()
    }
    
    // life cycle
    
    func setMenu(_ menu: NSMenu)
    {
        self.item?.menu = menu
    }
    
    func destory()
    {
        let bar = NSStatusBar.system()
        bar.removeStatusItem(self.item!)
    }
    
    func sendText(_ text: String)
    {
        //AXHelper.sendText(text)
        sendCGEventText(str: text)
    }
    
    // menu manipulate
    
    // menu
    // ----
    // 0 - title
    // 1 - conf file
    // 2 - ==
    // 3 - ==
    // 4 - quit
    
    struct Consts
    {
        static let mainMenuBaseLength = 7
        static let mainMenuItemBegin = 2
        static let mainMenuItemSuffix = mainMenuBaseLength - mainMenuItemBegin
    }
    
    func menuCleanup()
    {
        let menu = self.item?.menu
        let n = menu?.numberOfItems
        
        if(n! > Consts.mainMenuBaseLength)
        {
            for _ in Consts.mainMenuBaseLength ..< n!
            {
                menu?.removeItem(at: Consts.mainMenuItemBegin)
            }
        }
    }
    
    func buildMenu(_ desc: [String])
    {
        // clean up first
        menuCleanup()
        
        let menu = self.item?.menu
        
        var basePath:[String] = []
        var curEmoticon = String()
        let spaceSet = CharacterSet.whitespacesAndNewlines
        
        for line in desc
        {
            if(line.hasPrefix("--"))
            {
                continue
            }
            else if(line.hasPrefix("#"))
            {
                let index = line.index(line.endIndex, offsetBy: (line.characters.count - 1) * -1)
                var pathStr = line.substring(from: index)
                pathStr = pathStr.trimmingCharacters(in: spaceSet)
                basePath = pathStr.components(separatedBy: ".")
            }
            else
            {
                curEmoticon = line.trimmingCharacters(in: spaceSet)

                if(curEmoticon.characters.count == 0)
                {
                    continue
                }
            
                var pathComp = basePath
                pathComp.append(curEmoticon)
                
                insertMenuItem(menu!, path: pathComp)
            }
        }
    }
    
    func insertMenuItem(_ menu: NSMenu, path: [String])
    {
        var curMenu = menu
        for i in 0 ..< path.count
        {
            let name = path[i]
            let isleaf = (i == path.count-1)
            
            let idxBegin = (i == 0) ? Consts.mainMenuItemBegin : 0
            let idxEnd = (i == 0) ? curMenu.numberOfItems - Consts.mainMenuItemSuffix : curMenu.numberOfItems
            var matchedItem: NSMenuItem? = nil;
            
            // find the item
            for idx in idxBegin ..< idxEnd
            {
                let item = curMenu.item(at: idx)
                if item?.title == name
                {
                    matchedItem = item
                    break
                }
            }
            
            // no match, create one
            if(matchedItem == nil)
            {
                matchedItem = NSMenuItem(
                    title: name,
                    action: nil,
                    keyEquivalent: "")
                curMenu.insertItem(matchedItem!, at: idxEnd)
            }
            
            if(isleaf)
            {
                matchedItem?.target = self
                matchedItem?.action = #selector(NekoBar.onEmoticonClicked(_:))
            }
            else
            {
                // iterate
                // no submenu, create one
                if(matchedItem?.submenu == nil)
                {
                    let subMenu = NSMenu(title: "submenu");
                    matchedItem?.submenu = subMenu;
                }
                
                curMenu = (matchedItem?.submenu)!
            }
        }
    }
    
    func onEmoticonClicked(_ sender: AnyObject)
    {
        let menuItem = sender as! NSMenuItem
        let emoticon = menuItem.title
        
        sendText(emoticon)
    }
    
}
