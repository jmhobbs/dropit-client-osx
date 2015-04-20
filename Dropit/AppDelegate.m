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
#import <SGDirWatchdog.h>
#import <MASShortcut/Shortcut.h>

#define kAPIBase   @"DropitPrefsAPIBase"
#define kUsername  @"DropitPrefsUsername"
#define kPassword  @"DropitPrefsPassword"

static NSString *const kPreferenceGlobalScreenshotShortcut = @"GlobalScreenshotShortcut";

@interface AppDelegate ()

@property (strong, nonatomic) NSString *apiBase;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

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
    
    [_window close];
    
    _screenshotAutoUploader = [[ScreenshotAutoUploader alloc] init];
    _screenshotAutoUploader.delegate = self;
    
     if( ! [self loadConfig]) {
        [self clicked:_statusBarItem];
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

- (bool)loadConfig {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _apiBase = [prefs objectForKey:kAPIBase];
    _username = [prefs objectForKey:kUsername];
    _password = [prefs objectForKey:kPassword];
    return (nil != _apiBase && nil != _username && nil != _password);
}

- (IBAction)saveConfig:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_apiBase forKey:kAPIBase];
    [prefs setObject:_username forKey:kUsername];
    [prefs setObject:_password forKey:kPassword];
    [prefs synchronize];
}

- (void)clicked:(DropitStatusBarItem *)item {
     _configViewController = [[ConfigurationViewController alloc] initWithNibName:@"ConfigurationViewController" bundle:[NSBundle mainBundle]];
     _configViewController.delegate = self;
     
     _popover = [[NSPopover alloc] init];
     [_popover setContentSize:NSMakeSize(300.0f, 300.0f)];
     [_popover setContentViewController:_configViewController];
     [_popover setAnimates:YES];
     [_popover setBehavior:NSPopoverBehaviorTransient];
     [_popover showRelativeToRect:[item bounds] ofView:item preferredEdge:NSMaxYEdge];
}

- (void)doScreenshot {

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
            [_uploadController createUpload:[NSURL fileURLWithPath:tempFileName] withMimeType:@"image/png" fileName:@"Screen-Shot.png"];
            // TODO: Clean up after upload.
        }
        else {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:tempFileName error:&error];
            if (error.code != NSFileNoSuchFileError) {
                NSLog(@"Error removing temporary screenshot file: %@", error);
            }
        }
    }];
    
    [task launch];
}

- (void)loginTouchUp {
    PopoverViewController *vc = [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:[NSBundle mainBundle]];
    vc.datasource = _uploadController;
    [_popover setContentViewController:vc];
}

- (void)fileDropped:(NSURL *)url {
    [_uploadController createUpload:url];
}

- (void)newFileToUpload:(NSURL *)url {
    [_uploadController createUpload:url];
}

@end
