//
//  AppDelegate.m
//  Dropit
//
//  Created by John Hobbs on 3/24/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "AppDelegate.h"
#import "DropitStatusBarItem.h"
#import "PopoverViewController.h"
#import "Upload.h"
#import "UploadController.h"
#import "ConfigurationManager.h"
#import <SGDirWatchdog.h>
#import <MASShortcut/Shortcut.h>
#import <ServiceManagement/SMLoginItem.h>
#import <UICKeyChainStore.h>

#define kAPIBase   @"DropitPrefsAPIBase"
#define kUsername  @"DropitPrefsUsername"
#define kPassword  @"DropitPrefsPassword"

static NSString *const kPreferenceGlobalScreenshotShortcut = @"GlobalScreenshotShortcut";

@interface AppDelegate ()

@property (strong, nonatomic) UploadController *uploadController;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) ScreenshotAutoUploader *screenshotAutoUploader;

@property (strong, nonatomic) DropitStatusBarItem *statusBarItem;

@property (strong, nonatomic) ConfigurationViewController *configViewController;

@property (strong, nonatomic) NSPopover *popover;

@property (strong, nonatomic) NSSet *screenShotFilesOnDesktop;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:16];
    _statusItem.title = nil;
    
    _statusBarItem = [[DropitStatusBarItem alloc] initWithFrame:_statusItem.view.frame];
    _statusBarItem.delegate = self;
    [_statusItem setView:_statusBarItem];

    _uploadController = [[UploadController alloc] init];
    _uploadController.statusBarItem = _statusBarItem;
    
    if(![[ConfigurationManager instance] load]) {
       [self clicked:_statusBarItem];
    }

    SMLoginItemSetEnabled((__bridge CFStringRef)@"org.velvetcache.Dropit", [ConfigurationManager instance].autostart);
    
    if([ConfigurationManager instance].uploadScreenshots) {
        _screenshotAutoUploader = [[ScreenshotAutoUploader alloc] init];
        _screenshotAutoUploader.delegate = self;
    }

    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_5 modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
    [[MASShortcutBinder sharedBinder] registerDefaultShortcuts:@{kPreferenceGlobalScreenshotShortcut: shortcut}];
    
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:kPreferenceGlobalScreenshotShortcut
     toAction:^{ [self doScreenshot]; }];
}

- (void)terminate:(id)sender {
    [[NSApplication sharedApplication] terminate:self.statusItem.menu];
}

- (void)clicked:(DropitStatusBarItem *)item {
    if( ! _popover) {
        _popover = [[NSPopover alloc] init];
        [_popover setContentSize:NSMakeSize(300.0f, 300.0f)];
        [_popover setContentViewController:_configViewController];
        [_popover setAnimates:YES];
        [_popover setBehavior:NSPopoverBehaviorTransient];
    }
    
    if(! [[ConfigurationManager instance] isLoggedIn]) {
        _configViewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:[NSBundle mainBundle]];
        _configViewController.delegate = self;
        [_popover setContentViewController:_configViewController];
    }
    else {
        PopoverViewController *vc = [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:[NSBundle mainBundle]];
        vc.datasource = _uploadController;
        [_popover setContentViewController:vc];
    }
    
     [_popover showRelativeToRect:[item bounds] ofView:item preferredEdge:NSMaxYEdge];
}

- (void)doScreenshot {
    if(! [[ConfigurationManager instance] isLoggedIn]) { return; }
    
    NSString *tempFileTemplate =
    [NSTemporaryDirectory() stringByAppendingPathComponent:@"Screen Shot _XXXXXX"];
    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
    strcpy(tempFileNameCString, tempFileTemplateCString);
    int fileDescriptor = mkstemp(tempFileNameCString);
    
    if (fileDescriptor == -1) {
        // handle file creation failure
    }
    
    // This is the file name if you need to access the file by name, otherwise you can remove
    // this line.
    NSString *tempFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString length:strlen(tempFileNameCString)];
    free(tempFileNameCString);
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/sbin/screencapture";
    task.arguments = @[@"-t", @"png", @"-is", tempFileName];

    [task setTerminationHandler:^(NSTask * task) {
        if(task.terminationStatus == 0) {
            Upload *upload = [_uploadController createUpload:[NSURL fileURLWithPath:tempFileName] withMimeType:@"image/png" fileName:@"Screen-Shot.png"];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tempFileUploadStateChanged:)
                                                         name:UploadStateChangedNotification
                                                       object:upload];
        }
        else {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:tempFileName error:&error];
            if (error && error.code != NSFileNoSuchFileError) {
                NSLog(@"Error removing temporary screenshot file: %@", error);
            }
        }
    }];
    
    [task launch];
}

- (void)tempFileUploadStateChanged:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    if([userInfo[kUploadState] integerValue] == UploadStateComplete) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadStateChangedNotification object:[notification object]];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:[((Upload *)notification.object).fileURL path] error:&error];
        if (error && error.code != NSFileNoSuchFileError) {
            NSLog(@"Error removing temporary screenshot file: %@", error);
        }
    }
}

- (void)loginSuccessful:(NSString *)host username:(NSString *)username password:(NSString *)password {
    ConfigurationManager *manager = [ConfigurationManager instance];
    manager.server = host;
    manager.username = username;
    manager.password = password;
    if([manager store]) {
        PopoverViewController *vc = [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:[NSBundle mainBundle]];
        vc.datasource = _uploadController;
        [_popover setContentViewController:vc];
    }
    else {
        NSLog(@"Damn.");
        // TODO
    }
}

- (bool)fileDropped:(NSURL *)url {
    if(! [[ConfigurationManager instance] isLoggedIn]) { return NO; }
    [_uploadController createUpload:url];
    return YES;
}

- (void)newFileToUpload:(NSURL *)url {
    if(! [[ConfigurationManager instance] isLoggedIn]) { return; }
    [_uploadController createUpload:url];
}

@end
