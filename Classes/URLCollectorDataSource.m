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

NSString *const NSPasteboardTypeURLCollectorElement = @"NSPasteboardTypeURLCollectorElement";

#define UNCLASSIFIED_GROUP_INDEX 0

@implementation URLCollectorDataSource

@synthesize urlCollectorElements;
@synthesize selectedElements;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[urlCollectorElements release];
	[selectedElements release];
	[super dealloc];
}

- (void)awakeFromNib
{
	urlCollectorElements = [[NSMutableArray alloc] initWithCapacity:1];
	selectedElements = [[NSMutableArray alloc] init];

	URLCollectorGroup *unclassifiedGroup = [[URLCollectorGroup alloc] init];
	unclassifiedGroup.name = NSLocalizedString(@"Inbox", @"");
	[self addGroup:unclassifiedGroup];
	[unclassifiedGroup release];
}

#pragma mark -
#pragma mark Public Methods

- (void)addMockData
{
	URLCollectorGroup *group = [[URLCollectorGroup alloc] init];
	group.name = SKStringWithFormat(@"Group #%d", [urlCollectorElements count] + 1);
	
	for(int i = 0; i < 10; i++) {
		URLCollectorElement *element = [[URLCollectorElement alloc] init];
		element.name = SKStringWithFormat(@"Child #%d", i);
		[group add:element];
		[element release];
	}
	
	[self willChangeValueForKey:@"urlCollectorElements"];
	[urlCollectorElements addObject:group];
	[self didChangeValueForKey:@"urlCollectorElements"];
	[group release];
	
}

- (void)addGroup:(URLCollectorGroup *)group
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	[urlCollectorElements addObject:group];
	[self didChangeValueForKey:@"urlCollectorElements"];
	
}

- (void)addGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index
{
	
}

- (void)addElement:(URLCollectorElement *)element
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	[(URLCollectorGroup *)[urlCollectorElements objectAtIndex:UNCLASSIFIED_GROUP_INDEX] add:element];
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group
{
	[self addElement:element toGroup:group atIndex:-1];
}

- (void)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	
	NSUInteger groupIndex = [urlCollectorElements indexOfObject:group];
	if(NSNotFound == groupIndex) {
		[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.GroupNotFoundException" reason:@"" userInfo:nil] raise];
	}
	[[urlCollectorElements objectAtIndex:groupIndex] add:element atIndex:index];
	
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)removeGroup:(URLCollectorGroup *)group
{
	[self removeGroup:group removeChildren:NO];
}

- (void)removeGroup:(URLCollectorGroup *)group removeChildren:(BOOL)shouldRemoveChildren
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	
	if(!shouldRemoveChildren) {
		URLCollectorGroup *unclassifiedGroup = [urlCollectorElements objectAtIndex:UNCLASSIFIED_GROUP_INDEX];
		NSArray *groupChildren = [[NSArray alloc] initWithArray:group.children];
		[group removeAllChildren];
		for(URLCollectorElement *child in groupChildren) {
			[unclassifiedGroup add:child];
		}
		[groupChildren release];
	}
	[urlCollectorElements removeObject:group];
	
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)removeElement:(URLCollectorElement *)element
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	[element.parentGroup remove:element];
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)removeElement:(URLCollectorElement *)element fromGroup:(URLCollectorGroup *)group
{
	
}

- (void)moveGroup:(URLCollectorGroup *)group toIndex:(NSInteger)newIndex
{
	NSInteger oldIndex = [urlCollectorElements indexOfObject:group];
	if(oldIndex == newIndex) {
		return;
	}
	
	[self willChangeValueForKey:@"urlCollectorElements"];
	
	if(newIndex == 0) {
		[urlCollectorElements removeObjectAtIndex:oldIndex];
		[urlCollectorElements insertObject:group atIndex:newIndex];
	}
	else if(newIndex > oldIndex) {
		if(newIndex >= [urlCollectorElements count]) {
			[urlCollectorElements addObject:group];
		}
		else {
			[urlCollectorElements insertObject:group atIndex:newIndex];
		}
		[urlCollectorElements removeObjectAtIndex:oldIndex];
	}
	else {
		[urlCollectorElements removeObjectAtIndex:oldIndex];
		[urlCollectorElements insertObject:group atIndex:newIndex];
	}
	[self didChangeValueForKey:@"urlCollectorElements"];
	
//	[self willChangeValueForKey:@"urlCollectorElements"];
//	[urlCollectorElements removeObjectAtIndex:oldGroupIndex];
//	if(index < [urlCollectorElements count]) {
//		[urlCollectorElements insertObject:group atIndex:index];
//	}
//	else {
//		[urlCollectorElements addObject:group];
//	}
//	[self didChangeValueForKey:@"urlCollectorElements"];
	
}

- (void)moveElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group
{
	
}

#pragma mark -
#pragma mark NSOutlineViewDataSource - Drag and Drop support

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
	TRACE(@"");
	
	// Simple check to determine whether the user has selected mixed element types (groups + children) or a single type (just groups; just children)
	NSSet *itemClasses = [NSSet setWithArray:[items valueForKeyPath:@"representedObject.class"]];
	if([itemClasses count] > 1) {
		WARN(@"***** NOT CURRENTLY SUPPORTING DRAGGING OF MIXED CLASSES");
		return NO;
	}

	NSArray *indexPaths = [items valueForKey:@"indexPath"];
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexPaths];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeURLCollectorElement] owner:self];
	[pasteboard setData:data forType:NSPasteboardTypeURLCollectorElement];
	
	[outlineView deselectAll:nil];
	return YES;
}

#define DRAG_TYPE_GROUP 1
#define DRAG_TYPE_CHILD 2
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
	id representedObject = [item representedObject];
//	TRACE(@"Represented object <%@> :: index <%d>", representedObject, index);

	if([info draggingSource] == nil) {
		if([representedObject isKindOfClass:[URLCollectorGroup class]]) {
			return NSDragOperationCopy;
		}
		return NSDragOperationNone;
	}
	if([info draggingSource] != outlineView) {
		return NSDragOperationNone;
	}
	
//	if([info draggingDestinationWindow] != [outlineView window]) {
//		TRACE(@"DRAGGED OUTSIDE THE WINDOW");
//		return NSDragOperationDelete;
//	}
	
	NSData *draggedData = [[info draggingPasteboard] dataForType:NSPasteboardTypeURLCollectorElement];
	NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:draggedData];
	NSInteger dragType = [[draggedIndexPaths lastObject] length];
	switch(dragType) {
		case DRAG_TYPE_GROUP:
			return (representedObject == nil ? NSDragOperationMove : NSDragOperationNone);
			
		case DRAG_TYPE_CHILD:
			return ([representedObject isKindOfClass:[URLCollectorGroup class]] ? NSDragOperationMove : NSDragOperationNone);
			
		default:
			WARN(@"INVALID/UNSUPPORTED DROP OPERATION!");
			return NSDragOperationNone;
	}
	
	return NSDragOperationNone;
//	BOOL isDropAllowed = [representedObject isKindOfClass:[URLCollectorGroup class]];
//	return isDropAllowed ? NSDragOperationCopy : NSDragOperationNone;
}

#define INDEXPATH_GROUP_POSITION	0
#define INDEXPATH_ELEMENT_POSITION	1
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
	TRACE(@"");
//	NSAssert([[item representedObject] isKindOfClass:[URLCollectorGroup class]], @"");
	
	if([info draggingSource] == nil) {
		URLCollectorGroup *destinationGroup = [item representedObject];
		NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
		for(NSPasteboardItem *pasteboardItem in [[info draggingPasteboard] pasteboardItems]) {
			URLCollectorElement *element = [[URLCollectorElement alloc] init];
			element.name = SKStringWithFormat(@"%@ (via %@)", [pasteboardItem stringForType:@"public.url-name"], [activeApp objectForKey:@"NSApplicationName"]);
			element.elementURL = [pasteboardItem stringForType:NSPasteboardTypeString];
			[self addElement:element toGroup:destinationGroup atIndex:index];
			[element release];
		}
	}
	else if([info draggingSource] == outlineView) {
		NSData *draggedData = [[info draggingPasteboard] dataForType:NSPasteboardTypeURLCollectorElement];
		NSArray *draggedIndexPaths = [NSKeyedUnarchiver unarchiveObjectWithData:draggedData];
		
		NSEnumerator *enumerator = [draggedIndexPaths reverseObjectEnumerator];
		NSIndexPath *indexPath = nil;
		while(indexPath = [enumerator nextObject]) {
			URLCollectorGroup *sourceGroup = [urlCollectorElements objectAtIndex:[indexPath indexAtPosition:INDEXPATH_GROUP_POSITION]];
			
			switch([indexPath length]) {
				case DRAG_TYPE_CHILD: {
					TRACE(@"Moving children to index <%d>", index);
					URLCollectorGroup *destinationGroup = [item representedObject];
					URLCollectorElement *element = [sourceGroup.children objectAtIndex:[indexPath indexAtPosition:INDEXPATH_ELEMENT_POSITION]];
					[self addElement:element toGroup:destinationGroup atIndex:index];
					break;
				}
				case DRAG_TYPE_GROUP:
					TRACE(@"Moving group <%@> to index <%d>...", sourceGroup, index);
					[self moveGroup:sourceGroup toIndex:index];
					break;
				default:
					NSAssert(NO, @"Unsupported indexPath length.");
			}
			 // !!! IMPORTANT !!! 
			 // since we're inserting the elements in reverse order, we need to adjust the insertion index at every iteration
			 // this is to ensure that the elements preserve the original order
			index = MAX(0, index-1);
		}
		TRACE(@"IndexPaths: %@", draggedIndexPaths);
	}
	
	return YES;
}

- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items
{
	TRACE(@"");
	
	return nil;
}

@end

