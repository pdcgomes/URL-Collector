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

#pragma mark -
#pragma mark NSView overrides

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
	if(flag) {
		return NSDragOperationAll;
	}
	return NSDragOperationCopy;
}

#pragma mark -
#pragma mark NSTableView overrides

//- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent *)dragEvent offset:(NSPointPointer)dragImageOffset
//{
//	NSImage *dragImage = [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns event:dragEvent offset:dragImageOffset];
//	[dragImage setBackgroundColor:[NSColor blackColor]];
//	return dragImage;
//}

//- (void)highlightSelectionInClipRect:(NSRect)clipRect
//{
//	
//}
//
//- (NSColor *)_highlightColorForCell:(NSCell *)cell
//{
//	return nil;
//}

@end
