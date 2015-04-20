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

- (Upload *)createUpload:(NSURL *)url {
    [_statusBarItem setImage:[NSImage imageNamed:@"drop_0"]];
    
    Upload *upload = [[Upload alloc] initWithURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadCreated:)
                                                 name:UploadCreatedNotification
                                               object:upload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadStateChanged:)
                                                 name:UploadStateChangedNotification
                                               object:upload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadProgress:)
                                                 name:UploadProgressNotification
                                               object:upload];
    
    
    [upload start];
    [_uploads addObject:upload];
    
    return upload;
}

- (Upload *)createUpload:(NSURL *)url withMimeType:(NSString *)mime fileName:(NSString *)fileName {
    [_statusBarItem setImage:[NSImage imageNamed:@"drop_0"]];
    
    Upload *upload = [[Upload alloc] initWithURL:url mimeType:mime fileName:fileName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadCreated:)
                                                 name:UploadCreatedNotification
                                               object:upload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadStateChanged:)
                                                 name:UploadStateChangedNotification
                                               object:upload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadProgress:)
                                                 name:UploadProgressNotification
                                               object:upload];
    
    
    [upload start];
    [_uploads addObject:upload];
    
    return upload;
}

- (void)uploadCreated:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:userInfo[kUploadDirectURL] forType:NSStringPboardType];
    
    NSString *resourcePath = @"/System/Library/Sounds/Glass.aiff";
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:resourcePath byReference:YES];
    [sound play];
}

- (void)uploadStateChanged:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    if([userInfo[kUploadState] integerValue] == UploadStateFailed) {
        NSString *resourcePath = @"/System/Library/Sounds/Basso.aiff";
        NSSound *sound = [[NSSound alloc] initWithContentsOfFile:resourcePath byReference:YES];
        [sound play];
    }
}

- (void)uploadProgress:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *progress = [userInfo objectForKey:kUploadProgress];
    float fprogress = [progress floatValue];
    
    NSLog(@"%@ - %f", progress, fprogress);
    
    if(fprogress < 0.1) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_0"]];
    }
    else if (fprogress < 0.25) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_10"]];
    }
    else if (fprogress < 0.40) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_25"]];
    }
    else if (fprogress < 0.50) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_40"]];
    }
    else if (fprogress < 0.65) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_50"]];
    }
    else if (fprogress < 0.75) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_65"]];
    }
    else if (fprogress < 0.90) {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop_90"]];
    }
    else {
        [_statusBarItem setImage:[NSImage imageNamed:@"drop"]];
    }
}

- (NSInteger)numberOfUploads {
    return [_uploads count];
}

- (Upload *)uploadAtIndex:(NSInteger)index {
    return [_uploads objectAtIndex:index];
}

@end
