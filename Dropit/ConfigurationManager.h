//
//  ConfigurationManager.h
//  Dropit
//
//  Created by John Hobbs on 4/21/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigurationManager : NSObject

@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property bool autostart;
@property bool uploadScreenshots;

+ (ConfigurationManager *)instance;

- (bool)load;
- (bool)store;
- (void)reset;

- (bool)isLoggedIn;

@end