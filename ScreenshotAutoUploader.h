//
//  ScreenshotAutoUploader.h
//  Dropit
//
//  Created by John Hobbs on 4/17/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScreenshotAutoUploaderDelegate <NSObject>

- (void)newFileToUpload:(NSURL *)url;

@end

@interface ScreenshotAutoUploader : NSObject

@property id<ScreenshotAutoUploaderDelegate> delegate;

@end
