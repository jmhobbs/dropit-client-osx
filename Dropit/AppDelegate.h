//
//  AppDelegate.h
//  Dropit
//
//  Created by John Hobbs on 3/24/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DropitStatusBarItem.h"
#import "ConfigurationViewController.h"
#import "ScreenshotAutoUploader.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, DropitStatusBarItemProtocol, ConfigurationViewControllerDelegate, ScreenshotAutoUploaderDelegate>


@end

