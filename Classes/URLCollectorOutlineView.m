//
//  URLCollectorOutlineView.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/10/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorOutlineView.h"
#import "URLCollectorDataSource.h"

@implementation URLCollectorOutlineView

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self registerForDraggedTypes:[NSArray arrayWithObjects:/*NSPasteboardTypeString, NSPasteboardTypeHTML, NSPasteboardTypeRTF, */NSURLPboardType, NSPasteboardTypeURLCollectorElement, nil]];
}

//- (void)setupMouseTrackingArea
//{
//	NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] 
//																options:(NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow|NSTrackingEnabledDuringMouseDrag)
//																  owner:self userInfo:nil];
//	[self addTrackingArea:trackingArea];
//	[trackingArea release];
//}
//
//#pragma mark -
//#pragma mark NSTrackingAreaDelegate
//
//- (void)mouseEntered:(NSEvent *)theEvent
//{
//	TRACE(@"Mouse entered");
//}
//
//- (void)mouseExited:(NSEvent *)theEvent
//{
//	TRACE(@"Mouse exited");	
//}

@end
