//
//  AppDelegate.h
//  VATRP
//
//  Created by Ruben Semerjyan on 8/27/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginWindowController.h"
#import "LoginViewController.h"
#import "HomeWindowController.h"
#import "VideoCallWindowController.h"
#import "ContactsWindowController.h"
#import "RecentsWindowController.h"
#import "ChatWindowController.h"
#import "ViewController.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) LoginWindowController *loginWindowController;
@property (nonatomic, retain) LoginViewController *loginViewController;
@property (nonatomic, retain) HomeWindowController *homeWindowController;
@property (nonatomic, retain) ViewController *viewController;
@property (weak) IBOutlet NSMenuItem *menuItemPreferences;
@property (weak) IBOutlet NSMenuItem *menuItemSignOut;



@property (nonatomic, retain) ContactsWindowController *contactsWindowController;
@property (nonatomic, retain) RecentsWindowController *recentsWindowController;
@property (nonatomic, retain) SettingsWindowController *settingsWindowController;
@property (nonatomic, retain) VideoMailWindowController *videoMailWindowController;
@property (nonatomic, retain) ChatWindowController *chatWindowController;


+ (AppDelegate*)sharedInstance;
- (void) showTabWindow;
- (void) closeTabWindow;
- (VideoCallWindowController*) getVideoCallWindow;

-(NSPoint) getTabWindowSize;
-(NSPoint) getTabWindowOrigin;
-(void) setTabWindowPos:(NSPoint) pos;
-(void) SignOut;

@end

