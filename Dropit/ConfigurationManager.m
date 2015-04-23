//
//  ConfigurationManager.m
//  Dropit
//
//  Created by John Hobbs on 4/21/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "ConfigurationManager.h"
#import <UICKeyChainStore.h>

static NSString *const kKeychainServiceName = @"org.velvetcache.Dropit";

static NSString *const kPreferenceServer = @"org.velvetcache.Dropit/server";
static NSString *const kPreferenceUsername = @"org.velvetcache.Dropit/username";
static NSString *const kPreferenceAutostart = @"org.velvetcache.Dropit/autostart";
static NSString *const kPreferenceUploadScreenshots = @"org.velvetcache.Dropit/upload_screenshots";


@implementation ConfigurationManager {
    UICKeyChainStore *keychain;
}

+ (ConfigurationManager *)instance {
    static ConfigurationManager *instance;
    if(!instance) {
        NSLog(@"Allocating instance.");
        instance = [[ConfigurationManager alloc] initInstance];
    }
    return instance;
}

- (instancetype)init { return nil; }

- (instancetype)initInstance {
    self = [super init];
    keychain = [UICKeyChainStore keyChainStoreWithService:kKeychainServiceName];
    [self reset];
    return self;
}

- (void)reset {
    _server = nil;
    _username = nil;
    _password = nil;
    _autostart = NO;
    _uploadScreenshots = NO;
}

- (bool)load {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    _server = [prefs objectForKey:kPreferenceServer];
    _username = [prefs objectForKey:kPreferenceUsername];
    _autostart = [prefs boolForKey:kPreferenceAutostart];
    _uploadScreenshots = [prefs boolForKey:kPreferenceUploadScreenshots];
    
    if( nil == _server || nil == _username) {
        [self reset];
        return NO;
    }
    
    NSError *error;
    _password = [keychain stringForKey:_username error:&error];
    if (error) {
        NSLog(@"Error loading password from keychain: %@", error.localizedDescription);
        [self reset];
        return NO;
    }
    
    return YES;
}

- (bool)store {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_server forKey:kPreferenceServer];
    [prefs setObject:_username forKey:kPreferenceUsername];
    [prefs setBool:_autostart forKey:kPreferenceAutostart];
    [prefs setBool:_uploadScreenshots forKey:kPreferenceUploadScreenshots];
    [prefs synchronize];
    
    NSError *error;
    [keychain setString:_password forKey:_username error:&error];
    // There is an exception here because overwrites _do_ work, but throw this
    // error code which isn't even actually listed in SecBase.h.
    if (error && error.code != -34018) {
        NSLog(@"Error storing password to keychain: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}

- (bool)isLoggedIn {
    return (_server && _username && _password);
}

@end
