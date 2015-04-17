//
//  ConfigurationViewController.m
//  Dropit
//
//  Created by John Hobbs on 4/10/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "ConfigurationViewController.h"

@interface ConfigurationViewController ()

@property (weak) IBOutlet NSTextField *serverHostname;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSProgressIndicator *activitySpinner;

- (IBAction)loginButtonPressed:(id)sender;

@end

@implementation ConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.delegate loginTouchUp];
}

@end
