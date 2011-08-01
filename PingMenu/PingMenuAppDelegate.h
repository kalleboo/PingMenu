//
//  PingMenuAppDelegate.h
//  PingMenu
//
//  Created by Baron Karl on 11/08/01.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SimplePing.h"

@interface PingMenuAppDelegate : NSObject <NSApplicationDelegate,SimplePingDelegate> {
    NSWindow *window;
    NSStatusItem* theItem;
    NSMenu* theMenu;
    NSMenuItem* menuLine1;
    NSMenuItem* menuLine2;
    SimplePing* pinger;
    NSTimer* pingTimer;
    NSMutableDictionary* pings;
    int sent;
    int received;
    int errored;
    int couldntSend;
    NSString* currentTitle;
    NSTimer* slowPingTimer;
    double lastDiff;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain,nonatomic) NSStatusItem* theItem;
@property (assign) IBOutlet NSMenu* theMenu;
@property (assign) IBOutlet NSMenuItem* menuLine1;
@property (assign) IBOutlet NSMenuItem* menuLine2;
@property (retain,nonatomic) SimplePing* pinger;
@property (retain,nonatomic) NSTimer* pingTimer;
@property (retain,nonatomic) NSMutableDictionary* pings;
@property (retain,nonatomic) NSString* currentTitle;
@property (retain,nonatomic) NSTimer* slowPingTimer;

-(IBAction)quitMe:(id)sender;

@end
