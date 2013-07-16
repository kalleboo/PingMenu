//
//  PingEvent.m
//  PingMenu
//
//  Created by Karl Baron on 2013/07/16.
//
//

#import "PingEvent.h"

@implementation PingEvent
@synthesize sequenceNr;
@synthesize state;
@synthesize sentTime;
@synthesize returnTime;
@synthesize resultError;

-(NSString*) stateName {
    switch (self.state) {
        case PingEventStateUnknown:
            return @"Sending";
        case PingEventStateSent:
            return @"Sent";
        case PingEventStateReceived:
            return @"Success";
        case PingEventStateSendError:
            return @"Error";
        default:
            return @"Unknown";
            break;
    }
}

-(double) timeSinceSent {
    if (!self.sentTime)
        return 0;

    if (!self.returnTime)
        return [NSDate timeIntervalSinceReferenceDate]-[self.sentTime timeIntervalSinceReferenceDate];

    return [self.returnTime timeIntervalSinceReferenceDate]-[self.sentTime timeIntervalSinceReferenceDate];
}

@end
