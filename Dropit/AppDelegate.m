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

@interface AppDelegate ()

@property (strong, nonatomic) UploadController *uploadController;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) DropitStatusBarItem *statusBarItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _uploadController = [[UploadController alloc] init];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:16];
    _statusItem.title = nil;
    
    _statusBarItem = [[DropitStatusBarItem alloc] initWithFrame:_statusItem.view.frame];
    _statusBarItem.delegate = self;
    [_statusItem setView:_statusBarItem];
    
    [_window close];
}

- (void)openConfig:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:self];
}

- (void)terminate:(id)sender {
    [[NSApplication sharedApplication] terminate:self.statusItem.menu];
}

- (IBAction)saveConfig:(id)sender {
//    _apiKey = [_apiKeyField stringValue]; 
//    _serverDomain = [_serverDomainField stringValue];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs setObject:_apiKey forKey:kPrefsAPIKey];
//    [prefs setObject:_serverDomain forKey:kPrefsServerDomain];
    [prefs synchronize];
}

- (void)clicked:(DropitStatusBarItem *)item {
    /*
    PopoverViewController *vc = [[PopoverViewController alloc] initWithNibName:@"PopoverViewController" bundle:[NSBundle mainBundle]];
    vc.datasource = _uploadController;
    
    NSPopover *popover = [[NSPopover alloc] init];
    [popover setContentSize:NSMakeSize(300.0f, 300.0f)];
    [popover setContentViewController:vc];
    [popover setAnimates:YES];
    [popover setBehavior:NSPopoverBehaviorTransient];
    [popover showRelativeToRect:[item bounds] ofView:item preferredEdge:NSMaxYEdge];
     */

}

- (void)fileDropped:(NSURL *)url {
    [_uploadController createUpload:url];
}

@end
