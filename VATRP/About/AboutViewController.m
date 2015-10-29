//
//  AboutViewController.m
//  VATRP
//
//  Created by Norayr Harutyunyan on 10/26/15.
//  Copyright (c) 2015 VTCSecure. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak) IBOutlet NSTextField *labelVersion;
@property (unsafe_unretained) IBOutlet NSTextView *textViewCopyright;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void) viewWillAppear {
    [super viewWillAppear];

    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    self.labelVersion.stringValue = [NSString stringWithFormat:@"Version %@", version];

    NSString* Copyright = [infoDict objectForKey:@"NSHumanReadableCopyright"];
//    [self.textViewCopyright setBackgroundColor:[NSColor clearColor]];
    self.textViewCopyright.string = Copyright;
}

@end
