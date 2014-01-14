//
//  PreferencesWindowController.m
//  PingMenu
//
//  Created by Gaurav Chandrashekar on 1/10/14.
//
//

#import "PreferencesWindowController.h"
#import "PingMenuAppDelegate.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    PingMenuAppDelegate *AppDelegate = (PingMenuAppDelegate *)[[NSApplication sharedApplication] delegate];
    self.domain.stringValue = AppDelegate.pingHost;
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)buttonPressed:(id)sender {
    NSLog(@"%@", self.domain.stringValue);
    
    PingMenuAppDelegate *AppDelegate = (PingMenuAppDelegate *)[[NSApplication sharedApplication] delegate];
    AppDelegate.pingHost = self.domain.stringValue;
    [self close];
}
@end
