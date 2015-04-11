//
//  PopoverViewController.h
//  Dropit
//
//  Created by John Hobbs on 3/30/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Upload.h"


@protocol PopoverViewControllerDataSource

- (NSInteger)numberOfUploads;
- (Upload *)uploadAtIndex:(NSInteger)index;

@end

@interface PopoverViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property id<PopoverViewControllerDataSource> datasource;

@end
