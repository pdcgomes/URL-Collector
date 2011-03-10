//
//  URLCollectorDataSource.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorDataSource.h"
#import "URLCollectorGroup.h"
#import "URLCollectorElement.h"
#import "URLCollectorNode.h"

NSString *column1Identifier = @"Column1";
NSString *column2Identifier = @"Column2";

@implementation URLCollectorDataSource

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[urlCollectorElements release];
	[selectedElements release];
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		urlCollectorElements = [[NSMutableArray alloc] initWithCapacity:1];
		selectedElements = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)addGroup:(URLCollectorGroup *)group
{
	[urlCollectorElements addObject:group];
}

- (void)addElement:(URLCollectorElement *)element
{
	
}

- (void)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group
{
	
}

- (void)removeGroup:(URLCollectorGroup *)group
{
	[urlCollectorElements removeObject:group];
}

- (void)removeElement:(URLCollectorElement *)element
{
	
}

- (void)removeElement:(URLCollectorElement *)element fromGroup:(URLCollectorGroup *)group
{
	
}

- (void)moveElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group
{
	
}

#pragma mark -
#pragma mark NSOutlineViewDataSource - Required Methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	return [[(URLCollectorNode *)item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return ![(URLCollectorNode *)item isLeafNode];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	return [(URLCollectorNode *)item numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	if([[tableColumn identifier] isEqual:column1Identifier]) {
		return [(URLCollectorNode *)item name];
	}
	else if([[tableColumn identifier] isEqual:column2Identifier]) {
		return @"";
	}
	return @"";
}

#pragma mark -
#pragma mark NSOutlineViewDataSource - Optional Methods

///* Optional Methods
// */
//- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
//- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object;
//- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item;
//
///* Optional - Sorting Support
// This is the indication that sorting needs to be done. Typically the data source will sort its data, reload, and adjust selections.
// */
//- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors AVAILABLE_MAC_OS_X_VERSION_10_3_AND_LATER;
//
///* Optional - Drag and Drop support
// */
//
///* This method is called after it has been determined that a drag should begin, but before the drag has been started.  To refuse the drag, return NO.  To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  The drag image and other drag related information will be set up and provided by the outline view once this call returns with YES.  The items array is the list of items that will be participating in the drag.
// */
//- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard;
//
///* This method is used by NSOutlineView to determine a valid drop target. Based on the mouse position, the outline view will suggest a proposed child 'index' for the drop to happen as a child of 'item'. This method must return a value that indicates which NSDragOperation the data source will perform. The data source may "re-target" a drop, if desired, by calling setDropItem:dropChildIndex: and returning something other than NSDragOperationNone. One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position). On Leopard linked applications, this method is called only when the drag position changes or the dragOperation changes (ie: a modifier key is pressed). Prior to Leopard, it would be called constantly in a timer, regardless of attribute changes.
// */
//- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index;
//
///* This method is called when the mouse is released over an outline view that previously decided to allow a drop via the validateDrop method. The data source should incorporate the data from the dragging pasteboard at this time. 'index' is the location to insert the data as a child of 'item', and are the values previously set in the validateDrop: method.
// */
//- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index;
//
///* NSOutlineView data source objects can support file promised drags via by adding  NSFilesPromisePboardType to the pasteboard in outlineView:writeItems:toPasteboard:.  NSOutlineView implements -namesOfPromisedFilesDroppedAtDestination: to return the results of this data source method.  This method should returns an array of filenames for the created files (filenames only, not full paths).  The URL represents the drop location.  For more information on file promise dragging, see documentation on the NSDraggingSource protocol and -namesOfPromisedFilesDroppedAtDestination:.
// */
//- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;

@end
