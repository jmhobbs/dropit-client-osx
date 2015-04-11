//
//  DropListViewController.m
//  Dropit
//
//  Created by John Hobbs on 3/31/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "DropListViewController.h"

@interface DropListViewController ()

@property (strong, nonatomic) Upload *upload;
@property (weak) IBOutlet NSTextField *filenameLabel;
@property (weak) IBOutlet NSImageView *stateImage;

@end

@implementation DropListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"Dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UploadStateChangedNotification
                                                  object:_upload];
}


- (void)configureForUpload:(Upload *)upload {
    NSLog(@"Configure! %@", upload.filename);
    _upload = upload;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadStateChanged:)
                                                 name:UploadStateChangedNotification
                                               object:_upload];
}

- (void)updateUI {
    NSLog(@"Update!");
    [self stateChanged:_upload.state];
    [_filenameLabel setStringValue:_upload.filename];
}

- (void)uploadStateChanged:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"Upload State Changed");
    [self stateChanged:[userInfo[kUploadState] integerValue]];
}


- (void)stateChanged:(UploadState)state {
    switch (state) {
        case UploadStateNew:
            [_stateImage setImage:[NSImage imageNamed:@"cloud"]];
            break;
        case UploadStateFailed:
            [_stateImage setImage:[NSImage imageNamed:@"cloud_fail"]];
            break;
        case UploadStateComplete:
            [_stateImage setImage:[NSImage imageNamed:@"cloud_ok"]];
            break;
        default:
            [_stateImage setImage:[NSImage imageNamed:@"cloud_upload"]];
            break;
    }
}

@end
