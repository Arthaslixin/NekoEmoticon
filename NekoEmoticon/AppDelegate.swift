//
//  AppDelegate.swift
//  NekoEmoticon
//
//  Created by arthas on 17/2/4.
//  Copyright (c) 2017年 arthas. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menu: NSMenu!

    var bar: NekoBar? = nil;
    var url: URL? = nil;

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        setShowDockIcon(false)
        self.bar = NekoBar.instance
        self.bar?.setMenu(self.menu)
        
        // read configuration file line by line
        let url = Bundle.main.url(forResource: "MenuDesc", withExtension: "conf")
        let confstr = try? NSString(contentsOf: url!, encoding: 4)
        let lines = confstr?.components(separatedBy: CharacterSet.newlines)
        
        // build the menu based on conf file
        self.bar?.buildMenu(lines! as [String])
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        self.bar?.destory()
    }

    func setShowDockIcon(_ show: Bool)
    {
        var result: Bool
        if (show)                               // What is ActivationPolicy
        {
            result = NSApp.setActivationPolicy(NSApplicationActivationPolicy.regular)
        }
        else
        {
            result = NSApp.setActivationPolicy(NSApplicationActivationPolicy.accessory)
        }
        
        if (!result)
        {
            NSLog("func setShowDockIcon(%@): NSApp.setActivationPolicy failed",
                show ? "true" : "false")
        }
    }
    
    @IBAction func act(_ sender:AnyObject)
    {
        self.bar?.sendText("orzorzstosto")
    }
    
    @IBAction func menuShowConfigFile(_ sender:AnyObject)
    {
        let url = Bundle.main.url(forResource: "MenuDesc", withExtension: "conf")
//        NSLog("%@", ((url as NSURL?)?.filePathURL)!)
        NSWorkspace.shared().activateFileViewerSelecting([ (url! as AnyObject) as! URL])
    }
    
    @IBAction func menuShowAbout(_ sender:AnyObject)
    {
        NSApplication.shared().orderFrontStandardAboutPanel(sender)
        NSApp.activate(ignoringOtherApps: true)             //Why we need this
        
    }
}

