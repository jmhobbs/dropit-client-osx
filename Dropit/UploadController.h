//
//  UploadController.h
//  Dropit
//
//  Created by John Hobbs on 4/10/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PopoverViewController.h"
#import "DropitStatusBarItem.h"

@interface UploadController : NSObject <PopoverViewControllerDataSource>

@property (strong, nonatomic) DropitStatusBarItem *statusBarItem;

- (void)createUpload:(NSURL *)url;
- (void)createUpload:(NSURL *)url withMimeType:(NSString *)mime fileName:(NSString *)fileName;

@end
