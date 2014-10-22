//
//  PingMenuAppDelegate.m
//  PingMenu
//
//  Created by Baron Karl on 11/08/01.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PingMenuAppDelegate.h"
#import "PingEvent.h"

#include <sys/socket.h>
#include <netdb.h>

#define DEFAULTS_HOSTNAME @"hostName"

#define COLOR_SLOW [NSColor colorWithCalibratedRed:0.755 green:0.345 blue:0.000 alpha:1.000]
#define COLOR_BAD [NSColor redColor]

@implementation PingMenuAppDelegate
@synthesize window;
@synthesize theMenu;
@synthesize pinger;
@synthesize theItem;
@synthesize pingTimer;
@synthesize updateTimer;
@synthesize pings;
@synthesize latestError;
@synthesize currentTitle;
@synthesize menuRow0;
@synthesize menuRow1;
@synthesize menuRow2;
@synthesize menuRow3;
@synthesize menuRow4;
@synthesize menuRow5;
@synthesize menuRow6;
@synthesize menuRow7;
@synthesize menuRow8;
@synthesize menuRow9;
@synthesize pingHost=_pingHost;

-(IBAction)quitMe:(id)sender {
    exit(0);
}

- (PreferencesWindowController *) prefWindowController {
    if(!_prefWindowController) {
        _prefWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    }
    
    return _prefWindowController;
}

-(BOOL)isDarkModeOn {
    //http://stackoverflow.com/questions/25379525/how-to-detect-dark-mode-in-yosemite-to-change-the-status-bar-menu-icon
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    return ( style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );
}

-(NSColor*)colorForGoodStatus {
    return darkModeOn?[NSColor whiteColor]:[NSColor blackColor];
}

-(void)resetMenu {
    NSString* formatted = @"Ping";
    self.menuRow0.title = formatted;
    self.menuRow1.title = formatted;
    self.menuRow2.title = formatted;
    self.menuRow3.title = formatted;
    self.menuRow4.title = formatted;
    self.menuRow5.title = formatted;
    self.menuRow6.title = formatted;
    self.menuRow7.title = formatted;
    self.menuRow8.title = formatted;
    self.menuRow9.title = formatted;
}

-(void)setupPinger {
    [self.pinger stop];
    [self resetMenu];
    self.pings = [[[NSMutableDictionary alloc] init] autorelease];
    self.pinger = [SimplePing simplePingWithHostName:self.pingHost];
    self.lastSeen = [NSDate date];
    pinger.delegate = self;
    [pinger start];
    
}

- (NSString *) pingHost {
    if(!_pingHost){
        _pingHost = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_HOSTNAME];
        if (!_pingHost) {
            _pingHost = @"google.com";
        }
    }
    return _pingHost;
    
}

-(void)setPingHost:(NSString *)pingHost {
    if (![pingHost isEqualToString:_pingHost]) {
        _pingHost = pingHost;
        [[NSUserDefaults standardUserDefaults] setObject:pingHost forKey:DEFAULTS_HOSTNAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setupPinger];
    }
}

-(IBAction)openPreferences:(id)sender {
    [self.prefWindowController showWindow:self];
}

- (void)activateStatusMenu
{
    didStart = NO;
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    self.currentTitle = @"Ping";
    
    self.theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem setTitle: NSLocalizedString(@"Ping",@"")];
    [theItem setHighlightMode:YES];
    [theItem setMenu:theMenu];

    [self setupPinger];
}

- (void)darkModeChanged:(id)notification {
    darkModeOn = [self isDarkModeOn];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    darkModeOn = [self isDarkModeOn];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(darkModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    
    [self activateStatusMenu];
}

-(void)updateMenuWithError:(NSString*)errString {
    self.latestError = errString;
    NSAttributedString* title = [[[NSAttributedString alloc] initWithString:errString attributes:[NSDictionary dictionaryWithObject:COLOR_BAD forKey:NSForegroundColorAttributeName]] autorelease];
    [theItem setAttributedTitle:title];    
}

-(void)updateMenu {
    NSArray* keys = [[self.pings allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSNumber*)obj2 compare:(NSNumber*)obj1];
    }];
    
    PingEvent* lastSuccessfulEvent = NULL;
    PingEvent* lastFailedEvent = NULL;
    PingEvent* lastSentEvent = NULL;
    PingEvent* earliestSentEvent = NULL;
    
    NSMutableArray* removeKeys = [NSMutableArray array];
    int n = 0;
    for (NSNumber* seq in keys) {
        if (n>9) {
            [removeKeys addObject:seq];
            continue;
        }
        
        PingEvent* ev = [self.pings objectForKey:seq];
        if (!lastSuccessfulEvent && ev.state==PingEventStateReceived)
            lastSuccessfulEvent = ev;
        
        if (!lastFailedEvent && ev.state==PingEventStateSendError)
            lastFailedEvent = ev;
        
        if (!lastSentEvent && ev.state==PingEventStateSent)
            lastSentEvent = ev;
        
        if (!lastSuccessfulEvent && ev.state==PingEventStateSent)
            earliestSentEvent = ev;
        
        NSString* time = [NSString stringWithFormat:@"%1.3fs",[ev timeSinceSent]];
        
        NSString* formatted = [NSString stringWithFormat:@"#%d: %@, %@",ev.sequenceNr,[ev stateName],time];
        //NSLog(@"%@",formatted);
        
        switch (n) {
            case 0:
                self.menuRow0.title = formatted;
                break;
            case 1:
                self.menuRow1.title = formatted;
                break;
            case 2:
                self.menuRow2.title = formatted;
                break;
            case 3:
                self.menuRow3.title = formatted;
                break;
            case 4:
                self.menuRow4.title = formatted;
                break;
            case 5:
                self.menuRow5.title = formatted;
                break;
            case 6:
                self.menuRow6.title = formatted;
                break;
            case 7:
                self.menuRow7.title = formatted;
                break;
            case 8:
                self.menuRow8.title = formatted;
                break;
            case 9:
                self.menuRow9.title = formatted;
                break;
                
            default:
                break;
        }
        
        if (self.latestError && n==0 && ev.state==PingEventStateReceived)
            self.latestError = nil;
        
        n++;
    }

    if (lastSuccessfulEvent)
        didStartHasSucceeded = YES;
    
    NSString* titleText = @"";
    NSColor* titleColor = [self colorForGoodStatus];
    
    if (self.latestError) {
        titleText = self.latestError;
        titleColor = COLOR_BAD;
        
    } else if (!didStartHasSucceeded) {
        titleText = @"Ping";
        
    } else if (lastFailedEvent && lastSuccessfulEvent && lastFailedEvent.sequenceNr > lastSuccessfulEvent.sequenceNr) {
        titleText = [self parseError:lastFailedEvent.resultError];
        titleColor = COLOR_BAD;
    
    } else if (!lastSuccessfulEvent && didStartHasSucceeded) {
        if (self.lastSeen) {
            NSTimeInterval since = [NSDate timeIntervalSinceReferenceDate]-[self.lastSeen timeIntervalSinceReferenceDate];
            
            if (since>120) {
                titleText = [NSString stringWithFormat:@"(no response in %.0fm)",floor(since/60)];
            } else {
                titleText = [NSString stringWithFormat:@"(no response in %.0fs)",floor(since)];
            }
        } else {
            titleText = @"(no reponse)";
        }
        
        titleColor = COLOR_BAD;

        /*
    } else if (!lastSuccessfulEvent && didStartHasSucceeded) {
        titleColor = COLOR_BAD;
        titleText = @"(no response)";
         */
    } else if ((!lastSuccessfulEvent || earliestSentEvent.sequenceNr > lastSuccessfulEvent.sequenceNr) && [earliestSentEvent timeSinceSent]>10) {
        titleColor = COLOR_BAD;
        titleText = @"(over 10s)";
        
    } else if ([lastSentEvent timeSinceSent] > [lastSuccessfulEvent timeSinceSent]+.1 && lastSentEvent.sequenceNr>lastSuccessfulEvent.sequenceNr) {
        titleColor = COLOR_SLOW;
        titleText = [NSString stringWithFormat:@"%1.3fs",[lastSuccessfulEvent timeSinceSent]];
        
    } else if (lastSuccessfulEvent) {
        titleText = [NSString stringWithFormat:@"%1.3fs",[lastSuccessfulEvent timeSinceSent]];
    }
    
    
    NSAttributedString* title = [[[NSAttributedString alloc] initWithString:titleText attributes:[NSDictionary dictionaryWithObject:titleColor forKey:NSForegroundColorAttributeName]] autorelease];
    [theItem setAttributedTitle:title];

    [self.pings removeObjectsForKeys:removeKeys];
}




- (NSString *)_shortErrorFromError:(NSError *)error
// Given an NSError, returns a short error string that we can print, handling 
// some special cases along the way.
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    assert(error != nil);
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) ) {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = [NSString stringWithUTF8String:failureStr];
                    assert(result != nil);
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    assert(result != nil);
    return result;
}

-(NSString*) parseError:(NSString*)errName {
    if ([errName isEqualToString:@"nodename nor servname provided, or not known"]) {
        return @"(dns failure)";
    } else if ([errName isEqualToString:@"No route to host"]) {
        return @"(no route)";
    } else {
        NSLog(@"PingMenu: Error %@",errName);
        return @"(failed)";
    }
}



//called when simplePing is ready
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    if (didStart) {
        [self sendPing];
        return;
    }
    
    didStart = YES;
    [self sendPing];

    /*
     self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
     */
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector:@selector(sendPing)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(sendPing)];
    [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:5 invocation:invocation repeats:YES] forMode:NSRunLoopCommonModes];
    
    invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector:@selector(updateMenu)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(updateMenu)];
    [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:.5 invocation:invocation repeats:YES] forMode:NSRunLoopCommonModes];
}

-(PingEvent*) eventForSeqNr:(int)seqNr {
    return [pings objectForKey:[NSNumber numberWithInt:seqNr]];
}

//send on timer loop
- (void)sendPing {
    unsigned int seq = self.pinger.nextSequenceNumber;
    PingEvent* ev = [[PingEvent alloc] init];
    ev.state = PingEventStateUnknown;
    ev.sequenceNr = seq;
    ev.sentTime = [NSDate date];
    [self.pings setObject:ev forKey:[NSNumber numberWithInt:seq]];
    [self.pinger sendPingWithData:nil];
    
    [self updateMenu];
    
    if (seq >= 65533) { //we're hitting int_max, restart it
        [self setupPinger];
    }
}

- (void)simplePing:(SimplePing *)myPinger didFailWithError:(NSError *)error {
    //NSLog(@"failed: %@", [self _shortErrorFromError:error]);
    NSString* errName = [self _shortErrorFromError:error];
    
    [self updateMenuWithError:[self parseError:errName]];
    
    if (!didStart) // try again
        [pinger start];
}

// Called whenever the SimplePing object has successfully sent a ping packet.
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet {
    unsigned int seq = (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber);
    //NSLog(@"#%u sent %@", seq,[NSString stringWithFormat:@"%u",seq]);
    PingEvent* ev =[self eventForSeqNr:seq];
    if (!ev)
        return;
    
    ev.state = PingEventStateSent;
    ev.sentTime = [NSDate date];

    [self updateMenu];
}

// Called whenever the SimplePing object tries and fails to send a ping packet.
- (void)simplePing:(SimplePing *)myPinger didFailToSendPacket:(NSData *)packet error:(NSError *)error {
    unsigned int seq = NSNotFound;
    
    const struct ICMPHeader* head = [SimplePing icmpInPacket:packet];
    if (head) {
        seq = (unsigned int) OSSwapBigToHostInt16(head->sequenceNumber);
        
    } else {
        [self simplePing:pinger didFailWithError:error];
        return;
    }
    
    PingEvent* ev =[self eventForSeqNr:seq];
    if (!ev) {
        [self simplePing:pinger didFailWithError:error];
        return;
    }

    ev.state = PingEventStateSendError;
    ev.returnTime = [NSDate date];
    ev.resultError = [self _shortErrorFromError:error];
    
    [self updateMenu];
}

// Called whenever the SimplePing object receives an ICMP packet that looks like 
// a response to one of our pings (that is, has a valid ICMP checksum, has 
// an identifier that matches our identifier, and has a sequence number in 
// the range of sequence numbers that we've sent out).
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet {
    unsigned int seq = (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber);
    //NSLog(@"#%u received", seq);
    PingEvent* ev =[self eventForSeqNr:seq];
    if (!ev)
        return;

    ev.state = PingEventStateReceived;
    ev.returnTime = [NSDate date];
    self.lastSeen = [NSDate date];

    [self updateMenu];
}

// Called whenever the SimplePing object receives an ICMP packet that does not 
// look like a response to one of our pings.
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    return;
    const ICMPHeader *  icmpPtr;
    NSString* msg = @"";
    icmpPtr = [SimplePing icmpInPacket:packet];
    
    if (icmpPtr->type==0)
        return;
    
    if (icmpPtr != NULL) {
        msg = [NSString stringWithFormat:@"#%u unexpected ICMP type=%u, code=%u, identifier=%u", (unsigned int) OSSwapBigToHostInt16(icmpPtr->sequenceNumber), (unsigned int) icmpPtr->type, (unsigned int) icmpPtr->code, (unsigned int) OSSwapBigToHostInt16(icmpPtr->identifier) ];
    } else {
        msg = [NSString stringWithFormat:@"unexpected packet size=%zu", (size_t) [packet length]];
    }

    //NSLog(@"%@",msg);
    [self updateMenuWithError:@"(invalid response)"];
}


@end
