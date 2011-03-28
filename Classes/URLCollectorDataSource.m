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
#import "URLCollectorContentClassifier.h"
#import "URLCollectorDatabaseManager.h"

#import "SKManagedObjectContextManager.h"

NSString *column1Identifier = @"Column1";
NSString *column2Identifier = @"Column2";

NSString *const NSPasteboardTypeURLCollectorElement = @"NSPasteboardTypeURLCollectorElement";

#define INBOX_GROUP_INDEX	0
#define DEFAULT_SAVE_DELAY	2.0

@interface URLCollectorDataSource() <URLCollectorDatabaseManagerDelegate, URLCollectorContentClassifierDelegate>

- (void)registerObservers;
- (void)deregisterObservers;

- (void)initializeDatabaseIfNeeded;
- (void)initializePersistentStoreIfNeeded;
- (void)loadPersistedGroups;

- (void)rebuildElementIndex;
- (void)indexElement:(URLCollectorElement *)element;
- (void)removeElementFromIndex:(URLCollectorElement *)element;
- (BOOL)elementIsIndexed:(URLCollectorElement *)element;

- (void)saveChangesInternal;
- (void)reloadLocalDatabase;

//- (void)fetchContextForElement:(URLCollectorElement *)element;
- (void)classifyElement:(URLCollectorElement *)element;

@end

@implementation URLCollectorDataSource

@synthesize managedObjectContext;
@synthesize outlineView = outlineView_;
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
	[operationQueue cancelAllOperations];
	[self deregisterObservers];

	outlineView_ = nil;

	[databaseManager release];
	[urlCollectorElements release];
	[selectedElements release];
	[operationQueue release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[self registerObservers];
	[self initializeDatabaseIfNeeded];
//	[self reloadLocalDatabase];
	
	selectedElements = [[NSMutableArray alloc] init];
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:5];
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

- (void)initializeDatabaseIfNeeded
{
	if(!databaseManager) {
		databaseManager = [[URLCollectorDatabaseManager alloc] initWithDatabaseFilePath:defaultSeralizationPath()];
		databaseManager.delegate = self;
	}
	[self reloadLocalDatabase];
	[databaseManager performSyncIfNeeded];
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
#pragma mark Index/Cache management

- (void)rebuildElementIndex
{
	if(elementIndex != nil) {
		[elementIndex removeAllObjects];
	}
	else {
		elementIndex = [[NSMutableDictionary alloc] init];
	}
	
	for(URLCollectorGroup *group in urlCollectorElements) {
		for(URLCollectorElement *element in group.children) {
			[self indexElement:element];
		}
	}
}

- (void)indexElement:(URLCollectorElement *)element
{
	TRACE(@"");
	NSUInteger groupIndex = [urlCollectorElements indexOfObject:element.parent];
	NSUInteger theElementIndex = [[[urlCollectorElements objectAtIndex:groupIndex] children] indexOfObject:element];
	
//	NSUInteger indexes[2] = {groupIndex, theElementIndex};
//	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:(NSUInteger[2]){groupIndex, theElementIndex} length:2];
	
	[elementIndex setObject:indexPath forKey:element.URL];
}

- (void)removeElementFromIndex:(URLCollectorElement *)element
{
	TRACE(@"");
	[elementIndex removeObjectForKey:element.URL];
}

- (BOOL)elementIsIndexed:(URLCollectorElement *)element
{
	return [elementIndex containsKey:element.URL];
}

#pragma mark -
#pragma mark Public Methods

- (void)addURLToInbox:(NSString *)URL
{
	URLCollectorGroup *inboxGroup = [urlCollectorElements objectAtIndex:0];
	[self addURL:URL toGroup:inboxGroup];
}

- (void)addURL:(NSString *)URL toGroup:(URLCollectorGroup *)destinationGroup
{
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	
	NSMutableArray *elements = [[NSMutableArray alloc] init];
	URLCollectorElement *element = [[URLCollectorElement alloc] init];
	element.URL = URL;
	[self addElement:element toGroup:destinationGroup];
	[elements addObject:element];
	[element release];
	
	// TODO: rethink this approach...
	void (^fetchContextBlock)(void) = ^{
		URLCollectorContext *context = [[[URLCollectorContextRecognizer sharedInstance] guessContextFromApplication:activeApp] retain];
		[elements makeObjectsPerformSelector:@selector(setContext:) withObject:context];
		[context release];
		
		[outlineView_ performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES]; // kind of bruteforce, but should be enough for now
	};
	
	NSBlockOperation *operation = [[NSBlockOperation alloc] init];
	[operation addExecutionBlock:fetchContextBlock];
	[operationQueue addOperation:operation];
	[operation release];
	// END TODO
	[elements release];
}

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
	if([self elementIsIndexed:element] && element.parent == nil) { // If parent != nil, it's safe to assume that this is just a move operation
		INFO(@"TODO: warn user that he attempted to insert an item with a duplicate URL...");
		return;
	}
	[self willChangeValueForKey:@"urlCollectorElements"];
	
	NSUInteger groupIndex = [urlCollectorElements indexOfObject:group];
	if(NSNotFound == groupIndex) {
		[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.GroupNotFoundException" reason:@"" userInfo:nil] raise];
	}
	[[urlCollectorElements objectAtIndex:groupIndex] add:element atIndex:index];
	
	[self didChangeValueForKey:@"urlCollectorElements"];
	[self indexElement:element];
}

- (void)removeGroup:(URLCollectorGroup *)group
{
	[self removeGroup:group removeChildren:NO];
}

- (void)removeGroup:(URLCollectorGroup *)group removeChildren:(BOOL)shouldRemoveChildren
{
	// FIXME: this may cause trouble when there are async operations for elements being removed here
	[self willChangeValueForKey:@"urlCollectorElements"];
	
	if(!shouldRemoveChildren) {
		URLCollectorGroup *inboxGroup = [urlCollectorElements objectAtIndex:INBOX_GROUP_INDEX];
		NSArray *groupChildren = [[NSArray alloc] initWithArray:group.children];
		[group removeAllChildren];
		for(URLCollectorElement *child in groupChildren) {
			[self addElement:child toGroup:inboxGroup];
		}
		[groupChildren release];
	}
	[urlCollectorElements removeObject:group];
	
	[self didChangeValueForKey:@"urlCollectorElements"];
}

- (void)removeElement:(URLCollectorElement *)element
{
	// FIXME: this may cause trouble when there are async operations for elements being removed here	
	
	[self willChangeValueForKey:@"urlCollectorElements"];
	[(URLCollectorGroup *)element.parent remove:element];
	[self didChangeValueForKey:@"urlCollectorElements"];

	[self removeElementFromIndex:element];
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
//	if(newIndex < 0) {
//		newIndex = [urlCollectorElements count] - 1;
//	}
	
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
	if(/*[[[SKManagedObjectContextManager sharedInstance] defaultManagedObjectContext] hasChanges] || */hasPendingChanges) {
		TRACE(@"***** SCHEDULING NEXT SAVE....");
		[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveChangesInternal) object:nil];
		[self performSelector:@selector(saveChangesInternal) withObject:nil afterDelay:DEFAULT_SAVE_DELAY];
	}
	else {
		INFO(@"saveChanges was called but no changes were made.");
	}
}

#pragma mark -
#pragma mark Private Methods - Database and sync

- (void)saveChangesInternal
{
	TRACE(@"***** SAVING CHANGES TO DISK...");
	[databaseManager saveData:urlCollectorElements];
	hasPendingChanges = NO;
}

- (void)reloadLocalDatabase
{
	NSArray *storedData = [databaseManager loadData];
	if(!storedData) {
		ERROR(@"Unable to load data");
		return; // TODO: handle error
	}

	// It may be better to just stop observing the appropriate element instead of 
	// unregistering all observers
	[self deregisterObservers];
	
	[self willChangeValueForKey:@"urlCollectorElements"];
	if(urlCollectorElements) {
		[urlCollectorElements removeAllObjects];
	}
	urlCollectorElements = [[NSMutableArray alloc] initWithArray:storedData];
	[self didChangeValueForKey:@"urlCollectorElements"];
	[self rebuildElementIndex];
	
	[self registerObservers];
}

#pragma mark -
#pragma mark Private Methods - Async operations

- (void)classifyElement:(URLCollectorElement *)element
{
	[[URLCollectorContentClassifier sharedInstance] classifyElement:element delegate:self];
}

#pragma mark -
#pragma mark NSOutlineViewDataSource

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	URLCollectorGroup *group = [item representedObject];
	
	[self willChangeValueForKey:@"urlCollectorElements"];
	[group setName:object];
	[self didChangeValueForKey:@"urlCollectorElements"];
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
	if(index < 0) {
		return NSDragOperationNone;
	}
	
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

		NSMutableArray *elements = [[NSMutableArray alloc] init];
		for(NSPasteboardItem *pasteboardItem in [[info draggingPasteboard] pasteboardItems]) {
			URLCollectorElement *element = [[URLCollectorElement alloc] init];
			element.URL = [pasteboardItem stringForType:NSPasteboardTypeString];
			element.URLName = [pasteboardItem stringForType:@"public.url-name"];
			[self addElement:element toGroup:destinationGroup atIndex:index];
			[elements addObject:element];
			[self classifyElement:element];
			[element release];
		}

		// FIXME: rethink this approach...
		void (^fetchContextBlock)(void) = ^{
			URLCollectorContext *context = [[[URLCollectorContextRecognizer sharedInstance] guessContextFromApplication:activeApp] retain];
			[elements makeObjectsPerformSelector:@selector(setContext:) withObject:context];
			[context release];
			
			[outlineView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES]; // kind of bruteforce, but should be enough for now
		};
		
		NSBlockOperation *operation = [[NSBlockOperation alloc] init];
		[operation addExecutionBlock:fetchContextBlock];
		[operationQueue addOperation:operation];
		[operation release];
		// END TODO
		[elements release];
		
//		[context release];
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
					[outlineView reloadItem:item];
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
#pragma mark URLCollectorDatabaseManagerDelegate

- (void)databaseManagerDidFinishSyncing:(URLCollectorDatabaseManager *)database
{
	[self reloadLocalDatabase];
}

#pragma mark -
#pragma mark URLCollectorContentClassifierDelegate

- (void)classificationForElement:(URLCollectorElement *)element didFinishWithResult:(NSDictionary *)classification
{
	// TODO: consider using reloadItem instead (efficiency)
	TRACE(@"Classification for element <%@> finished with result <%@>", element, classification);
	[self willChangeValueForKey:@"urlCollectorElements"];
	[element updateClassification:classification];
	[self didChangeValueForKey:@"urlCollectorElements"];
	
	[outlineView_ reloadData];
}

- (void)classificationForElement:(URLCollectorElement *)element didFailWithError:(NSError *)error
{
	
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

