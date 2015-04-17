//
//  ScreenshotAutoUploader.m
//  Dropit
//
//  Created by John Hobbs on 4/17/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "ScreenshotAutoUploader.h"
#import <SGDirWatchDog.h>

@interface ScreenshotAutoUploader ()

@property (strong, nonatomic) NSSet *currentDesktopState;
@property (strong, nonatomic) NSString *watchedPath;
@property (strong, nonatomic) SGDirWatchdog *observer;

@end

@implementation ScreenshotAutoUploader
{
    // Dodgy as hell
    NSRegularExpression *screenShotRegex;
}

- (id)init {
    self = [super init];
    
    if( ! screenShotRegex ) {
        screenShotRegex = [NSRegularExpression
           regularExpressionWithPattern:@"^Screen Shot [0-9]{4}-[0-9]{2}-[0-9]{2} at [0-9]+.[0-9]{2}.[0-9]{2} (AM|PM).(png|jpg)"
                                options:0
                                  error:nil
        ];
    }
    
    // Default to equivalent of ~/Desktop
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    _watchedPath = [paths objectAtIndex:0];
    _currentDesktopState = [self enumeratePath:_watchedPath];
    
    _observer = [[SGDirWatchdog alloc] initWithPath:_watchedPath  update:^{
        NSMutableSet *screenshots = [self enumeratePath:_watchedPath];
        NSSet *ssCopy = [screenshots copy];
        [screenshots minusSet:_currentDesktopState];
        for (NSString *fname in screenshots) {
            // TODO: Some kind of guard on ctime to prevent re-uploads
            [self.delegate newFileToUpload:[NSURL fileURLWithPathComponents:@[_watchedPath, fname]]];
        }
        _currentDesktopState = ssCopy;
    }];
    [_observer start];
    
    return self;
}

- (NSMutableSet *)enumeratePath:(NSString *)path {
    NSMutableSet *screenShots = [[NSMutableSet alloc] init];
    for (NSString *fname in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL]) {
        NSTextCheckingResult *match = [screenShotRegex firstMatchInString:fname
                                                                  options:0
                                                                    range:NSMakeRange(0, [fname length])];
        if(match) {
            [screenShots addObject:fname];
        }
    }
    return screenShots;
}


@end
