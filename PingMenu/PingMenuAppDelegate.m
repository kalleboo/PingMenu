//
//  PingMenuAppDelegate.m
//  PingMenu
//
//  Created by Baron Karl on 11/08/01.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PingMenuAppDelegate.h"

#include <sys/socket.h>
#include <netdb.h>

@implementation PingMenuAppDelegate
@synthesize window;
@synthesize theMenu;
@synthesize pinger;
@synthesize theItem;
@synthesize pingTimer;
@synthesize pings;
@synthesize menuLine1;
@synthesize menuLine2;
@synthesize currentTitle;
@synthesize slowPingTimer;

-(IBAction)quitMe:(id)sender {
    exit(0);
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    sent = 0;
    received = 0;
    errored = 0;
    couldntSend = 0;
    
    self.currentTitle = @"Ping";
    
    self.pings = [[NSMutableDictionary alloc] init];
    [pings release];
    
    self.pinger = [SimplePing simplePingWithHostName:@"74.125.236.81"];
    pinger.delegate = self;
    
    self.theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    
    [theItem setTitle: NSLocalizedString(@"Ping",@"")];
    [theItem setHighlightMode:YES];
    [theItem setMenu:theMenu];

    [pinger start];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self activateStatusMenu];
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

- (void)sendPing
// Called to send a ping, both directly (as soon as the SimplePing object starts up) 
// and via a timer (to continue sending pings periodically).
{
    [self.pinger sendPingWithData:nil];
    self.slowPingTimer = [NSTimer scheduledTimerWithTimeInterval:lastDiff+.1 target:self selector:@selector(slowPing) userInfo:nil repeats:NO];    
}

-(void)updateMenuTitleWithColor:(NSColor*)color {
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:self.currentTitle attributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName]];
    [theItem setAttributedTitle:title];
    [title release];
}

-(void)updateMenuCount {
    [menuLine1 setTitle:[NSString stringWithFormat:@"Sent: %d / Received: %d (Outstanding: %d / Error: %d) Couldn't send: %d", sent, received, (sent-received-errored),  errored, couldntSend]];
}

-(void)slowPing {
    [self updateMenuTitleWithColor:[NSColor colorWithCalibratedRed:0.755 green:0.345 blue:0.000 alpha:1.000]];
}

// Called after the SimplePing has successfully started up.  After this callback, you 
// can start sending pings via -sendPingWithData:
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [self sendPing];
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];    
}

// If this is called, the SimplePing object has failed.  By the time this callback is 
// called, the object has stopped (that is, you don't need to call -stop yourself).

// IMPORTANT: On the send side the packet does not include an IP header. 
// On the receive side, it does.  In that case, use +[SimplePing icmpInPacket:] 
// to find the ICMP header within the packet.
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
//    NSLog(@"failed: %@", [self _shortErrorFromError:error]);
    [menuLine2 setTitle:[NSString stringWithFormat:@"#%d %@", sent, [self _shortErrorFromError:error]]];
    errored++;
    [self updateMenuTitleWithColor:[NSColor redColor]];
}

// Called whenever the SimplePing object has successfully sent a ping packet. 
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
{
    unsigned int seq = (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber);
//    NSLog(@"#%u sent %@", seq,[NSString stringWithFormat:@"%u",seq]);
    [pings setObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:[NSString stringWithFormat:@"%u",seq]];
    sent++;
    [self updateMenuCount];
}

// Called whenever the SimplePing object tries and fails to send a ping packet.
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
//    NSLog(@"#%u send failed: %@", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber), [self _shortErrorFromError:error]);
    [menuLine2 setTitle:[NSString stringWithFormat:@"#%d %@", sent, [self _shortErrorFromError:error]]];
    couldntSend++;
}

// Called whenever the SimplePing object receives an ICMP packet that looks like 
// a response to one of our pings (that is, has a valid ICMP checksum, has 
// an identifier that matches our identifier, and has a sequence number in 
// the range of sequence numbers that we've sent out).
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
    unsigned int seq = (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber);
    double start = [[pings objectForKey:[NSString stringWithFormat:@"%u",seq]] doubleValue];
    [pings removeObjectForKey:[NSString stringWithFormat:@"%d",seq]];
    double diff = [NSDate timeIntervalSinceReferenceDate]-start;
    lastDiff = diff;
    
    [slowPingTimer invalidate];
    self.currentTitle = [NSString stringWithFormat:@"%1.3fs",diff];
    [self updateMenuTitleWithColor:[NSColor blackColor]];

//    NSLog(@"#%u received", seq);
    received++;
    [self updateMenuCount];
}

// Called whenever the SimplePing object receives an ICMP packet that does not 
// look like a response to one of our pings.
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    const ICMPHeader *  icmpPtr;
    
    icmpPtr = [SimplePing icmpInPacket:packet];
    if (icmpPtr != NULL) {
        NSLog(@"#%u unexpected ICMP type=%u, code=%u, identifier=%u", (unsigned int) OSSwapBigToHostInt16(icmpPtr->sequenceNumber), (unsigned int) icmpPtr->type, (unsigned int) icmpPtr->code, (unsigned int) OSSwapBigToHostInt16(icmpPtr->identifier) );
    } else {
        NSLog(@"unexpected packet size=%zu", (size_t) [packet length]);
    }    
}


@end
