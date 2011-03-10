//
//  URLCollectorOutlineView.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/10/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorOutlineView.h"

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
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:/*NSPasteboardTypeString, NSPasteboardTypeHTML, NSPasteboardTypeRTF, */NSURLPboardType, nil]];
}

#pragma mark -
#pragma mark Drag and Drop support

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
	TRACE(@"%@", sender);
	for(NSPasteboardItem *pasteboardItem in [[sender draggingPasteboard] pasteboardItems]) {
		TRACE(@"Types: %@", [pasteboardItem types]);
	}
	return [super draggingEntered:sender];
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
	BOOL accepted = [super prepareForDragOperation:sender];
	TRACE(@"Accepted: %d", accepted);
	return accepted;
}
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pasteboard
{
	TRACE(@"");
    // Copy the row numbers to the pasteboard.
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
//    [pasteboard declareTypes:[NSArray arrayWithObject:MyPrivateTableViewDataType] owner:self];
//    [pasteboard setData:data forType:MyPrivateTableViewDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    // Add code here to validate the drop
    TRACE(@"validate Drop");
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
	TRACE(@"");
	
//    NSPasteboard* pboard = [info draggingPasteboard];
//    NSData* rowData = [pboard dataForType:MyPrivateTableViewDataType];
//    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
//    NSInteger dragRow = [rowIndexes firstIndex];
	
    // Move the specified row to its new location...
	return YES;
}

@end
