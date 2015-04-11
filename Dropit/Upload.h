//
//  Upload.h
//  Dropit
//
//  Created by John Hobbs on 4/9/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UploadState) {
    UploadStateNew,
    UploadStateSigning,
    UploadStateSigned,
    UploadStateUploading,
    UploadStateUploaded,
    UploadStateCompleting,
    UploadStateComplete,
    UploadStateFailed
};

#define UploadCreatedNotification       @"UploadCreatedNotification"
#define UploadStateChangedNotification  @"UploadStateChangedNotification"
#define UploadProgressNotification      @"UploadProgressNotification"

#define kUploadViewURL    @"UploadCreatedViewURL"
#define kUploadDirectURL  @"UploadCreatedDirectURL"
#define kUploadState      @"UploadState"
#define kUploadProgress   @"UploadProgress"

@interface Upload : NSObject

@property UploadState state;
@property float uploadProgress;

@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic) NSString *mimeType;
@property (strong, nonatomic) NSNumber *size;

@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *viewURL;
@property (strong, nonatomic) NSString *directURL;

- (id)initWithURL:(NSURL *)fileURL;
- (void)start;

@end
