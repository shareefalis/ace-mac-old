//
//  DockView.m
//  ACE
//
//  Created by Norayr Harutyunyan on 11/10/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "DockView.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "ChatService.h"
#import "ResourcesWindowController.h"

@interface DockView () {
    NSButton *selectedDocViewItem;
    NSArray *dockViewButtons;
}

@property (weak) IBOutlet NSButton *buttonRecents;
@property (weak) IBOutlet NSButton *buttonContacts;
@property (weak) IBOutlet NSButton *buttonDialpad;
@property (weak) IBOutlet NSButton *buttonResources;
@property (weak) IBOutlet NSButton *buttonSettings;
@property (strong) ResourcesWindowController *resourcesWindowController;
@end


@implementation DockView

@synthesize delegate = _delegate;

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self setBackgroundColor:[NSColor colorWithRed:44.0/255.0 green:55.0/255.0 blue:61.0/255.0 alpha:1.0]];
    
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonRecents];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonContacts];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonDialpad];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonSettings];
    [Utils setButtonTitleColor:[NSColor whiteColor] Button:self.buttonResources];
    
    selectedDocViewItem = self.buttonDialpad;
    [selectedDocViewItem setWantsLayer:YES];
    [selectedDocViewItem.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
    dockViewButtons = [NSArray arrayWithObjects:self.buttonRecents, self.buttonContacts, self.buttonDialpad, self.buttonResources, self.buttonSettings, nil];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)onButtonRecents:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDockViewRecents:)]) {
        [_delegate didClickDockViewRecents:self];
    }    
}

- (IBAction)onButtonContacts:(id)sender {
//    AppDelegate *app = [AppDelegate sharedInstance];
//    if (!app.contactsWindowController) {
//        app.contactsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Contacts"];
//        [app.contactsWindowController showWindow:self];
//    } else {
//        if (app.contactsWindowController.isShow) {
//            [app.contactsWindowController close];
//        } else {
//            [app.contactsWindowController showWindow:self];
//            app.contactsWindowController.isShow = YES;
//        }
//    }

    if ([_delegate respondsToSelector:@selector(didClickDockViewContacts:)]) {
        [_delegate didClickDockViewContacts:self];
    }
}

- (IBAction)onButtonDialpad:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickDockViewDialpad:)]) {
        [_delegate didClickDockViewDialpad:self];
    }
}

- (IBAction)onButtonResources:(id)sender {
   // BOOL isOpenedChatWindow = [[ChatService sharedInstance] openChatWindowWithUser:nil];
   // if (isOpenedChatWindow) {
        if ([_delegate respondsToSelector:@selector(didClickDockViewResources:)]) {
            [_delegate didClickDockViewResources:self];
        }
    //}
    
    
//    self.resourcesWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Resources"];
//   [self.resourcesWindowController showWindow:self];
    

}

- (IBAction)onButtonSettings:(id)sender {
    AppDelegate *app = [AppDelegate sharedInstance];
    if (!app.settingsWindowController) {
        app.settingsWindowController = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"Settings"];
        [app.settingsWindowController showWindow:self];
//        if ([_delegate respondsToSelector:@selector(didClickDockViewSettings:)]) {
//            [_delegate didClickDockViewSettings:self];
//        }
    } else {
        if (app.settingsWindowController.isShow) {
            [app.settingsWindowController close];
            app.settingsWindowController = nil;
        } else {
            [app.settingsWindowController showWindow:self];
            app.settingsWindowController.isShow = YES;
//            if ([_delegate respondsToSelector:@selector(didClickDockViewSettings:)]) {
//                [_delegate didClickDockViewSettings:self];
//            }
        }
    }


//    if ([_delegate respondsToSelector:@selector(didClickDockViewSettings:)]) {
//        [_delegate didClickDockViewSettings:self];
//    }
}

#pragma mark - Functions for buttons background color chnages
- (void)clearDockViewButtonsBackgroundColorsExceptDialPadButton:(BOOL)clear {
    for (NSButton *bt in dockViewButtons) {
        if (clear) {
            [bt setWantsLayer:YES];
            [bt.layer setBackgroundColor:[NSColor clearColor].CGColor];
        } else {
            if (![bt.title isEqualToString:@"Dialpad"]) {
                [bt setWantsLayer:YES];
                [bt.layer setBackgroundColor:[NSColor clearColor].CGColor];
            }
        }
    }
}

- (void)clearDockViewSettingsBackgroundColor:(BOOL)clear {
    if (clear) {
        [self.buttonSettings setWantsLayer:YES];
        [self.buttonSettings.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [self.buttonSettings setWantsLayer:YES];
        [self.buttonSettings.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
    }
}

- (void)clearDockViewMessagesBackgroundColor:(BOOL)clear {
    if (clear) {
        [self.buttonResources setWantsLayer:YES];
        [self.buttonResources.layer setBackgroundColor:[NSColor clearColor].CGColor];
    } else {
        [self.buttonResources setWantsLayer:YES];
        [self.buttonResources.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
    }
}

- (void) selectItemWithDocViewItem:(DockViewItem)docViewItem {

    switch (docViewItem) {
        case DockViewItemRecents: {
            selectedDocViewItem = self.buttonRecents;
        }
            break;
        case DockViewItemContacts: {
            selectedDocViewItem = self.buttonContacts;
        }
            break;
        case DockViewItemDialpad: {
            selectedDocViewItem = self.buttonDialpad;
        }
            break;
        case DockViewItemResources: {
            selectedDocViewItem = self.buttonResources;
        }
            break;
        case DockViewItemSettings: {
            selectedDocViewItem = self.buttonSettings;
        }
            break;
            
        default:
            break;
    }

    [selectedDocViewItem setWantsLayer:YES];
    [selectedDocViewItem.layer setBackgroundColor:[NSColor colorWithRed:90.0/255.0 green:115.0/255.0 blue:128.0/255.0 alpha:1.0].CGColor];
}

@end
