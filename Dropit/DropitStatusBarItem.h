//
//  DropableImage.h
//  Junction
//
//  Created by John Hobbs on 3/24/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DropitStatusBarItem;

@protocol DropitStatusBarItemProtocol <NSObject>

- (void)clicked:(DropitStatusBarItem *)item;
- (void)fileDropped:(NSURL *)url;

@end

@interface DropitStatusBarItem : NSImageView <NSDraggingDestination>

@property id<DropitStatusBarItemProtocol> delegate;

- (NSRect)globalRect;

@end
