//
//  ConfigurationViewController.h
//  Dropit
//
//  Created by John Hobbs on 4/10/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ConfigurationViewControllerDelegate <NSObject>

- (void)loginTouchUp;

@end

@interface ConfigurationViewController : NSViewController

@property id<ConfigurationViewControllerDelegate> delegate;

@end
