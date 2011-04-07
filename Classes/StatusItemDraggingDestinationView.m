//
//  StatusItemView.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "StatusItemDraggingDestinationView.h"


@implementation StatusItemDraggingDestinationView

- (id)initWithStatusItem:(NSStatusItem *)theStatusItem
{
	if((self = [super initWithFrame:NSMakeRect(0, 0, 22, 22)])) {
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
	TRACE(@"");
	return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	TRACE(@"");
	
	return NSDragOperationCopy;	
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
	TRACE(@"");
	
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
	TRACE(@"");
	
	return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	TRACE(@"");
	
	NSArray *URLObjects = [[sender draggingPasteboard] readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:nil];
	for(NSURL *URL in URLObjects) {
		NSString *URLString = [URL description];
		[[NSNotificationCenter defaultCenter] postNotificationName:UCDroppedItemAtStatusBarNotification 
															object:self 
														  userInfo:[NSDictionary dictionaryWithObject:URLString forKey:UCDroppedItemDraggingInfoKey]];
	}
	return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
	TRACE(@"");
	
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
	TRACE(@"");
	
}

@end
