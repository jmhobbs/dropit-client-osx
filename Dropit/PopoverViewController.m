//
//  PopoverViewController.m
//  Dropit
//
//  Created by John Hobbs on 3/30/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "PopoverViewController.h"
#import "DropListViewController.h"


@interface PopoverViewController ()

@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    DropListViewController *vc = [[DropListViewController alloc] initWithNibName:@"DropListViewController" bundle:[NSBundle mainBundle]];
    [vc configureForUpload:[_datasource uploadAtIndex:row]];
    return vc.view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_datasource numberOfUploads];
}

- (BOOL)tableView:(NSTableView *)aTableView
shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return NO;
}

@end
