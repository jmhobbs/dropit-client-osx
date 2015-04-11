//
//  DropListViewController.h
//  Dropit
//
//  Created by John Hobbs on 3/31/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Upload.h"

@interface DropListViewController : NSViewController

- (void)configureForUpload:(Upload *)upload;

@end
