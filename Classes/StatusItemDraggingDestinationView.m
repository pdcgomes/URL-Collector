//
//  StatusItemView.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "StatusItemDraggingDestinationView.h"


@implementation StatusItemDraggingDestinationView

#define ITEM_WIDTH	22
#define ITEM_HEIGHT	22
- (id)initWithStatusItem:(NSStatusItem *)theStatusItem
{
	if((self = [super initWithFrame:NSMakeRect(0, 0, ITEM_WIDTH, ITEM_HEIGHT)])) {
		statusItem = theStatusItem;
		[self setImage:[theStatusItem image]];
		[self setImageFrameStyle:NSImageFrameNone];
		[self registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
	}
	return self;
}

//- (void)drawRect:(NSRect)dirtyRect 
//{
//	
//}

#pragma mark -
#pragma mark NSControl overrides

- (void)mouseDown:(NSEvent *)theEvent
{
	[statusItem popUpStatusItemMenu:[statusItem menu]];
}

#pragma mark -
#pragma mark Drag and Drop Support

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	return NSDragOperationCopy;	
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
	return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	NSArray *URLObjects = [[sender draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:nil];
	for(NSURL *URL in URLObjects) {
		NSString *URLString = [URL description]; // FIXME: replace with the actual NSURL object
		[[NSNotificationCenter defaultCenter] postNotificationName:UCDroppedItemAtStatusBarNotification 
															object:self 
														  userInfo:[NSDictionary dictionaryWithObject:URLString forKey:UCDroppedItemDraggingInfoKey]];
	}
	return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
}

@end
