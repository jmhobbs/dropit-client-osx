//
//  UploadController.m
//  Dropit
//
//  Created by John Hobbs on 4/10/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "UploadController.h"
#import "Upload.h"

@interface UploadController ()

@property (strong, nonatomic) NSMutableArray *uploads;

@end

@implementation UploadController

- (id)init {
    self = [super init];
    self.uploads = [[NSMutableArray alloc] init];
    return self;
}

- (void)createUpload:(NSURL *)url {
    Upload *upload = [[Upload alloc] initWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadCreated:)
                                                 name:UploadCreatedNotification
                                               object:upload];
    
    [upload start];
    [_uploads addObject:upload];
}

- (void)uploadCreated:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:userInfo[kUploadViewURL] forType:NSStringPboardType];
    
    NSString *resourcePath = @"/System/Library/Sounds/Glass.aiff";
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:resourcePath byReference:YES];
    [sound play];
}

- (NSInteger)numberOfUploads {
    return [_uploads count];
}

- (Upload *)uploadAtIndex:(NSInteger)index {
    return [_uploads objectAtIndex:index];
}

@end
