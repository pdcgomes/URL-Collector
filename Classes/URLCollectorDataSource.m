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

//- (id)init
//{
//	if((self = [super init])) {
//	}
//	return self;
//}

- (void)awakeFromNib
{
	urlCollectorElements = [[NSMutableArray alloc] initWithCapacity:1];
	selectedElements = [[NSMutableArray alloc] init];

	URLCollectorGroup *unclassifiedGroup = [[URLCollectorGroup alloc] init];
	unclassifiedGroup.name = NSLocalizedString(@"Unclassified", @"");
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
		for(URLCollectorElement *child in group.children) {
			[unclassifiedGroup add:child];
		}
	}
	[urlCollectorElements removeObject:group];
	
	[self didChangeValueForKey:@"urlCollectorElements"];
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
#pragma mark NSOutlineViewDataSource - Drag and Drop support

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
	TRACE(@"");
	NSAssert([[item representedObject] isKindOfClass:[URLCollectorGroup class]], @"");
	
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	
	URLCollectorGroup *destinationGroup = [item representedObject];
	for(NSPasteboardItem *pasteboardItem in [[info draggingPasteboard] pasteboardItems]) {
		URLCollectorElement *element = [[URLCollectorElement alloc] init];
		element.name = SKStringWithFormat(@"%@ (via %@)", [pasteboardItem stringForType:@"public.url-name"], [activeApp objectForKey:@"NSApplicationName"]);
		element.elementURL = [pasteboardItem stringForType:NSPasteboardTypeString];
		[self addElement:element toGroup:destinationGroup atIndex:index];
		[element release];
	}
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
	id representedObject = [item representedObject];
	TRACE(@"Represented object <%@> :: index <%d>", representedObject, index);

	BOOL isDropAllowed = [representedObject isKindOfClass:[URLCollectorGroup class]];
	return isDropAllowed ? NSDragOperationCopy : NSDragOperationNone;
}

- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items
{
	TRACE(@"");
	
	return nil;
}

@end

