//
//  AccountsViewController.m
//  vatrp
//
//  Created by Ruben Semerjyan on 9/22/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//
#import "AppDelegate.h"
#import "AccountsViewController.h"
#import "LinphoneManager.h"
#import "AccountsService.h"
#import "RegistrationService.h"
#import "Utils.h"

@interface AccountsViewController () {
    AccountModel *accountModel;
    BOOL isChanged;
}

@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSTextField *textFieldUserID;
@property (weak) IBOutlet NSSecureTextField *secureTextFieldPassword;
@property (weak) IBOutlet NSTextField *textFieldDomain;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSComboBox *comboBoxTransport;
@property (weak) IBOutlet NSTextField *settingsFeedbackText;

@end

@implementation AccountsViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    
    isChanged = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self setFields];
}

- (void)setFields {
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneProxyConfig *cfg=NULL;
    linphone_core_get_default_proxy(lc,&cfg);
    if (cfg) {
        const char *identity=linphone_proxy_config_get_identity(cfg);
        LinphoneAddress *addr=linphone_address_new(identity);
        
        // Get SIP Transport
        LinphoneTransportType transport = linphone_address_get_transport(addr);
        
        if(transport == LinphoneTransportUdp){
            linphone_address_set_transport(addr, LinphoneTransportTcp);
            transport = linphone_address_get_transport(addr);
        }
        
        NSString *sip_transport;
        switch (transport) {
            case LinphoneTransportTcp:
                sip_transport = @"Unencrypted (TCP)";
                break;
            case LinphoneTransportTls:
                sip_transport = @"Encrypted (TLS)";
                break;
            default:
                sip_transport = @"Unencrypted (TCP)";
                break;
        }
        [self.comboBoxTransport selectItemWithObjectValue:sip_transport];
    }
    
    accountModel = [[AccountsService sharedInstance] getDefaultAccount];
    
    if(accountModel){
        if(accountModel.username != NULL) { self.textFieldUsername.stringValue = accountModel.username; }
        if(accountModel.userID != NULL) { self.textFieldUserID.stringValue = accountModel.userID; }
        if(accountModel.password != NULL) { self.secureTextFieldPassword.stringValue = accountModel.password; }
        if(accountModel.domain != NULL) { self.textFieldDomain.stringValue = accountModel.domain; }
        if(accountModel.transport != NULL) {
            if([[accountModel.transport lowercaseString] isEqualToString:@"tls"]) {;
                [self.comboBoxTransport selectItemWithObjectValue:@"Encrypted (TLS)"];
                self.textFieldPort.stringValue = @"25061";
            } else {
                [self.comboBoxTransport selectItemWithObjectValue:@"Unencrypted (TCP)"];
                self.textFieldPort.stringValue = @"25060";
            }
        }
        if(accountModel.port > 0 ) {
            self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d", accountModel.port];
        }
    }
    else{
        self.textFieldDomain.stringValue = @"bc1.vatrp.net";
        self.textFieldPort.stringValue = @"25060";
        [self.comboBoxTransport selectItemWithObjectValue:@"Unencrypted (TCP)"];
    }
}

- (IBAction)onButtonAutoAnswer:(id)sender {
}

- (BOOL) save {
    if (!isChanged) {
        return YES;
    }
    
    if ([self checkFieldsValidness]) {
        return NO;
    }
    
    @try{
        [[AccountsService sharedInstance] removeAccountWithUsername:accountModel.username];
    }
    @catch(NSException *e){
        NSLog(@"Tried to remove account that does not exist.");
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *transport;
    if([self.comboBoxTransport.stringValue isEqualToString:@"Encrypted (TLS)"]) {
        transport=@"TLS";
    } else {
        transport=@"TCP";
    }
    
    [[AccountsService sharedInstance] addAccountWithUsername:self.textFieldUsername.stringValue
                                                      UserID:self.textFieldUserID.stringValue
                                                    Password:self.secureTextFieldPassword.stringValue
                                                      Domain:self.textFieldDomain.stringValue
                                                   Transport:transport
                                                        Port:self.textFieldPort.intValue
                                                   isDefault:YES];
    
    AccountModel *accountModel_ = [[AccountsService sharedInstance] getDefaultAccount];
    
    if (accountModel_) {
        [[RegistrationService sharedInstance] registerWithAccountModel:accountModel_];
    }
    
    self.settingsFeedbackText.stringValue = @"Settings saved";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeAccountsViewController" object:nil];
    
    return YES;
}

- (BOOL)checkFieldsValidness {
    
    BOOL error = NO;
    NSString *errorString = nil;
    
    if ([self.textFieldUsername.stringValue isEqual:@""]) {
        error = YES;
        errorString = @"Username field is required";
    }
    
    if ([self.secureTextFieldPassword.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Password field is required";
    }
    
    if ([self.textFieldDomain.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Domain field is required";
    }
    
    if ([self.textFieldPort.stringValue isEqual:@""] && !error) {
        error = YES;
        errorString = @"Port field is required";
    }
    
    if (error) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:errorString];
        [alert runModal];
    }
    
    return error;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    isChanged = YES;
}

- (IBAction)onComboboxTransport:(id)sender {
    isChanged = YES;
    
    if([self.comboBoxTransport.stringValue isEqualToString:@"Encrypted (TLS)"]) {
        if(self.textFieldPort.intValue == 25060) {
            self.textFieldPort.stringValue = @"25061";
        }
    } else {
        if(self.textFieldPort.intValue == 25061) {
            self.textFieldPort.stringValue = @"25060";
        }
    }
}

- (IBAction)onCheckBoxAutoAnswerCall:(id)sender {
    isChanged = YES;
}

@end
