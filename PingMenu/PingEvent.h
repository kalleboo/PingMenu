//
//  PingEvent.h
//  PingMenu
//
//  Created by Karl Baron on 2013/07/16.
//
//

#import <Foundation/Foundation.h>


typedef enum PingEventState {
    PingEventStateUnknown,
    PingEventStateSent,
    PingEventStateReceived,
    PingEventStateSendError,
    PingEventStateErrorUnexpectedPacket
    } PingEventState;

@interface PingEvent : NSObject {
    unsigned int sequenceNr;
    PingEventState state;
    NSDate* sentTime;
    NSDate* returnTime;
    NSString* resultError;
}

@property (nonatomic,assign) unsigned int sequenceNr;
@property (nonatomic,assign) PingEventState state;
@property (nonatomic,retain) NSDate* sentTime;
@property (nonatomic,retain) NSDate* returnTime;
@property (nonatomic,retain) NSString* resultError;

-(NSString*) stateName;
-(double) timeSinceSent;

@end
