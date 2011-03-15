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

#import "URLCollectorContextRecognizer.h"

#import "SKManagedObjectContextManager.h"

NSString *column1Identifier = @"Column1";
NSString *column2Identifier = @"Column2";

NSString *const NSPasteboardTypeURLCollectorElement = @"NSPasteboardTypeURLCollectorElement";

#define INBOX_GROUP_INDEX	0
#define DEFAULT_SAVE_DELAY	2.0

@interface URLCollectorDataSource()

- (void)registerObservers;
- (void)deregisterObservers;

- (void)initializePersistentStoreIfNeeded;
- (void)loadPersistedGroups;

@end

@implementation URLCollectorDataSource

@synthesize managedObjectContext;
@synthesize urlCollectorElements;
@synthesize selectedElements;


static NSString *defaultSeralizationPath(void)
{
	return [[[NSBundle mainBundle] applicationSupportPath] stringByAppendingPathComponent:@"database.db"];
}

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[self deregisterObservers];
	
	[urlCollectorElements release];
	[selectedElements release];
	[super dealloc];
}

- (void)awakeFromNib
{
	NSArray *unarchivedObjects =  nil;
	@try {
		unarchivedObjects = [NSKeyedUnarchiver unarchiveObjectWithFile:defaultSeralizationPath()];
	}
	@catch (NSException *e) {
		WARN(@"Caught exception while trying to unarchive database. Database file is possibly corrupted.");
		if([[NSFileManager defaultManager] fileExistsAtPath:defaultSeralizationPath()]) {
			[[NSFileManager defaultManager] removeItemAtPath:defaultSeralizationPath() error:nil];
		}
	}
	
	[self registerObservers];
	
	if(unarchivedObjects) {
		[self willChangeValueForKey:@"urlCollectorElements"];
		urlCollectorElements = [[NSMutableArray alloc] initWithArray:unarchivedObjects];
		[self didChangeValueForKey:@"urlCollectorElements"];
	}
	else {
		urlCollectorElements = [[NSMutableArray alloc] initWithCapacity:1];
		URLCollectorGroup *inboxGroup = [[URLCollectorGroup alloc] init];
		inboxGroup.name = defaultURLCollectorGroupName();
		[self addGroup:inboxGroup];
		[inboxGroup release];
	}
	selectedElements = [[NSMutableArray alloc] init];
}

- (void)initializePersistentStoreIfNeeded
{
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [SKManagedObjectContextManager sharedInstance].persistentStoreCoordinator;
	NSPersistentStore *persistentStore = [[persistentStoreCoordinator persistentStores] lastObject];
	BOOL persistentStoreInitialized = [[[persistentStoreCoordinator metadataForPersistentStore:persistentStore] objectForKey:@"IsInitialized"] boolValue];
	if(!persistentStoreInitialized) {
		SKManagedObjectContextManager *contextManager = [SKManagedObjectContextManager sharedInstance];
		URLCollectorGroup *inboxGroup = [contextManager insertNewEntityForName:@"URLCollectorGroup"];
		[inboxGroup setName:defaultURLCollectorGroupName()];
		[inboxGroup setSortOrder:0];
		[contextManager save];
		
		NSMutableDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:[persistentStoreCoordinator metadataForPersistentStore:persistentStore]];
		[metadata setObject:[NSNumber numberWithBool:YES] forKey:@"IsInitialized"];
		[persistentStoreCoordinator setMetadata:metadata forPersistentStore:persistentStore];
		[metadata release];
	}
}

- (void)loadPersistedGroups
{
	NSManagedObjectContext *context = [[SKManagedObjectContextManager sharedInstance] defaultManagedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"URLCollectorGroup" inManagedObjectContext:context]];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error = nil;
	NSArray *fetchResult = [context executeFetchRequest:fetchRequest error:&error];
	if(!fetchResult) {
		ERROR(@"");
	}
	else {
		[self willChangeValueForKey:@"urlCollectorElements"];
		[urlCollectorElements removeAllObjects];
		[urlCollectorElements addObjectsFromArray:fetchResult];
		[self didChangeValueForKey:@"urlCollectorElements"];
	}
	
	[sortDescriptor release];
	[fetchRequest release];
}

#pragma mark -
#pragma mark Public Methods

- (void)addGroup:(URLCollectorGroup *)group
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	[urlCollectorElements addObject:group];
	group.sortOrder = urlCollectorElements.count - 1;
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)addGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index
{
	
}

- (void)addElement:(URLCollectorElement *)element
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	[(URLCollectorGroup *)[urlCollectorElements objectAtIndex:INBOX_GROUP_INDEX] add:element];
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
		URLCollectorGroup *inboxGroup = [urlCollectorElements objectAtIndex:INBOX_GROUP_INDEX];
		NSArray *groupChildren = [[NSArray alloc] initWithArray:group.children];
		[group removeAllChildren];
		for(URLCollectorElement *child in groupChildren) {
			[inboxGroup add:child];
		}
		[groupChildren release];
	}
	[urlCollectorElements removeObject:group];
	
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)removeElement:(URLCollectorElement *)element
{
	[self willChangeValueForKey:@"urlCollectorElements"];
	[(URLCollectorGroup *)element.parent remove:element];
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
	group.sortOrder = newIndex;
	
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)moveElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group
{
	
}

- (void)saveChanges
{
	if([[[SKManagedObjectContextManager sharedInstance] defaultManagedObjectContext] hasChanges] || hasPendingChanges) {
		TRACE(@"***** SCHEDULING NEXT SAVE....");
		[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveChangesInternal) object:nil];
		[self performSelector:@selector(saveChangesInternal) withObject:nil afterDelay:DEFAULT_SAVE_DELAY];
	}
	else {
		INFO(@"saveChanges was called but no changes were made.");
	}
}

#pragma mark -
#pragma mark Private Methods

- (void)saveChangesInternal
{
	TRACE(@"***** SAVING CHANGES TO DISK...");
	[[SKManagedObjectContextManager sharedInstance] save];
	
	BOOL success = [NSKeyedArchiver archiveRootObject:urlCollectorElements toFile:defaultSeralizationPath()];
	TRACE(@"Archive success: %d", success);
	
	hasPendingChanges = NO;
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
}

#define INDEXPATH_GROUP_POSITION	0
#define INDEXPATH_ELEMENT_POSITION	1
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
	TRACE(@"");
	
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

#pragma mark -
#pragma mark KVO

- (void)registerObservers
{
	[self addObserver:self forKeyPath:@"urlCollectorElements" selector:@selector(urlCollectorElementsChanged:ofObject:change:userInfo:) userInfo:nil options:0];
}

- (void)deregisterObservers
{
	[self removeObserver:self keyPath:@"urlCollectorElements" selector:@selector(urlCollectorElementsChanged:ofObject:change:userInfo:)];
}

+ (NSSet *)keyPathsForValuesAffectingHasPendingChanges
{
	TRACE(@"");
	return [NSSet setWithObject:@"urlCollectorElements"];
}

- (void)urlCollectorElementsChanged:(NSString *)keyPath ofObject:(id)target change:(NSDictionary *)change userInfo:(id)userInfo
{
	TRACE(@"");
	hasPendingChanges = YES;
	[self saveChanges];
}

#pragma mark -
#pragma mark Application Notifications

- (void)applicationWillTerminate:(NSNotification *)notification
{
	TRACE(@"***** SAVING CHANGES BEFORE APPLICATION TERMINATION...");
	if(hasPendingChanges) {
		[self saveChangesInternal];
	}
}

@end

