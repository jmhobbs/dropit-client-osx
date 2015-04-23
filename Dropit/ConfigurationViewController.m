//
//  ConfigurationViewController.m
//  Dropit
//
//  Created by John Hobbs on 4/10/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "ConfigurationViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ConfigurationViewController ()

@property (weak) IBOutlet NSTextField *serverHostname;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSProgressIndicator *activitySpinner;

- (IBAction)loginButtonPressed:(id)sender;

@end

@implementation ConfigurationViewController

- (IBAction)loginButtonPressed:(id)sender {
    [_activitySpinner startAnimation:nil];

    NSString *password = [_password stringValue];
    NSString *username = [_username stringValue];
    NSString *hostname = [_serverHostname stringValue];
    
    [_serverHostname setEnabled:NO];
    [_username setEnabled:NO];
    [_password setEnabled:NO];
    [_loginButton setEnabled:NO];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:username
                                                              password:password];
    AFHTTPRequestOperation *check = [manager GET:[NSString stringWithFormat:@"%@/api/user/verify", hostname]
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"Baller.");
                                             
                                             [self.delegate loginSuccessful:hostname username:username password:password];
                                             
                                             [_activitySpinner stopAnimation:nil];                                             
                                             [_serverHostname setEnabled:YES];
                                             [_username setEnabled:YES];
                                             [_password setEnabled:YES];
                                             [_loginButton setEnabled:YES];
                                         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Damn:  %@", error);
                                             if(401 == operation.response.statusCode) {
                                                 NSLog(@"Unauthorized.");
                                             }
                                             else if (403 == operation.response.statusCode) {
                                                 NSLog(@"Forbidden");
                                             }
                                             [_activitySpinner stopAnimation:nil];
                                             [_serverHostname setEnabled:YES];
                                             [_username setEnabled:YES];
                                             [_password setEnabled:YES];
                                             [_loginButton setEnabled:YES];
                                         }];
    [check start];
}

@end
