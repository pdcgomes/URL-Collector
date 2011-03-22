//
//  StatusItemView.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "StatusItemDraggingDestinationView.h"


@implementation StatusItemDraggingDestinationView

- (id)initWithFrame:(NSRect)frame 
{
    if((self = [super initWithFrame:frame])) {
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil]];
	}
    return self;
}

- (void)drawRect:(NSRect)dirtyRect 
{
	
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
