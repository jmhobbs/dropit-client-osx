//
//  DropableImage.m
//  Junction
//
//  Created by John Hobbs on 3/24/15.
//  Copyright (c) 2015 John Hobbs. All rights reserved.
//

#import "DropitStatusBarItem.h"
#import "Upload.h"


@implementation DropitStatusBarItem

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:[NSImage imageNamed:@"drop"]];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                       NSColorPboardType, NSFilenamesPboardType, nil]];
    }
    return self;
}

- (void)mouseUp:(NSEvent *)theEvent {
    if(theEvent.modifierFlags & NSControlKeyMask) {
        [self rightMouseUp:theEvent];
    }
    else {
        if([self.delegate respondsToSelector:@selector(clicked:)]) {
            [self.delegate clicked:self];
        }
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"About" action:@selector(about) keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
}

- (void)about {
    NSLog(@"About");
    // TODO
}

- (void)quit {
    [[NSApplication sharedApplication] terminate:nil];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    if ([sender draggingSourceOperationMask] & NSDragOperationCopy) {
        return NSDragOperationCopy;
    }
    
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObjects:NSFilenamesPboardType, NSURLPboardType, nil]]) {
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    return [self.delegate fileDropped:[NSURL URLFromPasteboard:[sender draggingPasteboard]]];
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    /* Override to prevent self.image from changing. */
}

- (NSRect)globalRect {
    NSRect frame = [self frame];
    return [self.window convertRectToScreen:frame];
}

@end
