//
//  test.swift
//  Kaomewji
//
//  Created by arthas on 17/2/15.
//  Copyright (c) 2017年 arthas. All rights reserved.
//

import Foundation

import Cocoa
import CoreGraphics


func sendCGEventText(str: String)
{
    if(str.isEmpty)
    {
        return
    }
    
    let uni = str.utf16
    var fakeStr: [UniChar] = []
    
    for k in uni
    {
        fakeStr.append(UniChar(k))    
    }
    
    // splite the whole in batches
    let batch = 10
    var i = 0
    while i < fakeStr.count
    {
        let end = min(fakeStr.count, i + batch)
        let slice = Array(fakeStr[i...end-1])
        
        let eventSourcePtr = CGEventSource(stateID: .hidSystemState)
        
        let evPtr = CGEvent(keyboardEventSource: eventSourcePtr, virtualKey: CGKeyCode(0), keyDown: true)
        
        evPtr?.keyboardSetUnicodeString(stringLength: slice.count, unicodeString: slice)
        evPtr?.post(tap: CGEventTapLocation.cgSessionEventTap) //kCGHIDEventTap
        i += batch
    }
}

func sendCGEventTextTest()
{
    
    let eventSourcePtr = CGEventSource(stateID: .hidSystemState)
    
    let evPtr = CGEvent(keyboardEventSource: eventSourcePtr, virtualKey: CGKeyCode(0), keyDown: true)

    let fakeStr: [UniChar] = [65344]
    
    evPtr?.keyboardSetUnicodeString(stringLength: fakeStr.count, unicodeString: fakeStr)
    evPtr?.post(tap: CGEventTapLocation.cgSessionEventTap) //kCGHIDEventTap
}
