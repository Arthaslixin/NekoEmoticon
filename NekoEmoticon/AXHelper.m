//
//  AXHelper.m
//  NekoEmoticon
//
//  Created by arthas on 17/2/4.
//  Copyright (c) 2017年 arthas. All rights reserved.
//

#import "AXHelper.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation AXHelper

+(BOOL) checkAvailibility
{
    NSDictionary *options = @{(__bridge id) kAXTrustedCheckOptionPrompt : @YES};
    if(!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef) options))
    {
        NSLog(@"untrusted (w/opt)");
        return NO;
    }
    
    if(!AXIsProcessTrusted())
    {
        NSLog(@"untrused!");
        return NO;
    }
    
    return YES;
}

+(void) sendText:(NSString*) str
{
    if(![self checkAvailibility])
        return;
    
    CFTypeRef focusedUI;
    
    AXUIElementRef sysref = AXUIElementCreateSystemWide();
    if(!sysref) NSLog(@"sysref = null");
    
    AXError e = AXUIElementCopyAttributeValue(sysref, kAXFocusedUIElementAttribute, &focusedUI);
    if(e != kAXErrorSuccess) NSLog(@"focus error: %d", e);
    
    if (focusedUI) {
        CFTypeRef textValue, textRange;
        // get text content and range
        AXUIElementCopyAttributeValue(focusedUI, kAXValueAttribute, &textValue);
        AXUIElementCopyAttributeValue(focusedUI, kAXSelectedTextRangeAttribute, &textRange);
        
        NSRange range;
        AXValueGetValue(textRange, kAXValueCFRangeType, &range);
        
        NSLog(@"range(%lu,%lu)", range.location, range.length);
        
        // replace current range with new text
        NSString *newTextValue = [(__bridge NSString *)textValue stringByReplacingCharactersInRange:range withString:str];
        AXUIElementSetAttributeValue(focusedUI, kAXValueAttribute, (__bridge CFStringRef)newTextValue);
        // set cursor to correct position
        range.length = 0;
        range.location += str.length;
        AXValueRef valueRef = AXValueCreate(kAXValueCFRangeType, (const void *)&range);
        AXUIElementSetAttributeValue(focusedUI, kAXSelectedTextRangeAttribute, valueRef);
        
        CFRelease(textValue);
        CFRelease(textRange);
        CFRelease(focusedUI);
    }
    //else NSLog(@"no focused");
}

@end
