//
//  PreferencesWindowController.h
//  PingMenu
//
//  Created by Gaurav Chandrashekar on 1/10/14.
//
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController

@property (assign) IBOutlet NSTextField *domain;
@property (assign) IBOutlet NSButton *saveButton;

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
