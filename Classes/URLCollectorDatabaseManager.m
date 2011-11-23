//
//  URLCollectorDatabaseManager.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "URLCollectorDatabaseManager.h"
#import "URLCollectorGroup.h"
#import "URLCollectorElement.h"
#import "GTMFileSystemKQueue.h"

#define ASSERT_STATE(expectedState) do {\
NSAssert(state == expectedState, SKStringWithFormat(@"URLCollectorDatabaseManager :: invalid or unexpected state. Expected: <%d> Actual: <%d>", expectedState, state));\
}\
while(0)

static NSString *defaultSyncPath(void) 
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Dropbox"];
}

static NSString *defaultSyncDatabasePath(void)
{
	return [defaultSyncPath() stringByAppendingPathComponent:@".urlcollector/database.db"];
}

enum {
	kURLCollectorDatabaseManagerStateIsIdle = 0,
	kURLCollectorDatabaseManagerStateIsLoading,
	kURLCollectorDatabaseManagerStateIsSaving,
	kURLCollectorDatabaseManagerStateIsSyncing,
};

@interface URLCollectorDatabaseManager(Private)

- (void)saveDatabaseToSyncFolder;
- (void)startWatchingSyncFolderForChanges;
- (void)stopWatchingSyncFolderForChanges;
- (void)mergeChanges;

//- (void)lockSyncDatabase;
//- (void)unlockSyncDatabase;

@end

@implementation URLCollectorDatabaseManager

@synthesize delegate;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[self stopWatchingSyncFolderForChanges];
	self.delegate = nil;
	
	[databaseFilePath release];
	[databaseFileWatcher release];
	[changes release];
	[super dealloc];
}

- (id)initWithDatabaseFilePath:(NSString *)theDatabaseFilePath
{
	if((self = [super init])) {
		databaseFilePath = [theDatabaseFilePath copy];
		syncEnabled = YES;
		state = kURLCollectorDatabaseManagerStateIsIdle;
		changes = [[NSMutableArray alloc] init];
		changeTypes = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (NSArray *)loadData
{
	ASSERT_STATE(kURLCollectorDatabaseManagerStateIsIdle);
	state = kURLCollectorDatabaseManagerStateIsLoading;
	
	NSArray *loadedObjects =  nil;
	@try {
		loadedObjects = [NSKeyedUnarchiver unarchiveObjectWithFile:databaseFilePath];
		for(URLCollectorGroup *group in loadedObjects) {
			NSMutableArray *badObjects = [[NSMutableArray alloc] initWithCapacity:1];
			for(URLCollectorElement *child in group.children) {
				if(!child.URL) {
					[badObjects addObject:child];
				}
			}
			[group.children removeObjectsInArray:badObjects];
			[badObjects release];
		}
	}
	@catch (NSException *e) {
		WARN(@"Caught exception while trying to unarchive database. The database file could be corrupted.");
		if([[NSFileManager defaultManager] fileExistsAtPath:databaseFilePath]) {
			[[NSFileManager defaultManager] removeItemAtPath:databaseFilePath error:nil];
		}
	}
	if(!loadedObjects || [loadedObjects count] == 0) {
		URLCollectorGroup *inboxGroup = [[URLCollectorGroup alloc] init];
		inboxGroup.name = defaultURLCollectorGroupName();
		inboxGroup.isLocked = YES;
		loadedObjects = [NSArray arrayWithObject:inboxGroup];
		[inboxGroup release];
	}
	
	state = kURLCollectorDatabaseManagerStateIsIdle;
	return loadedObjects;
}

- (void)saveData:(NSArray *)data
{
	ASSERT_STATE(kURLCollectorDatabaseManagerStateIsIdle);

	TRACE(@"***** SAVING CHANGES TO DISK...");
	state = kURLCollectorDatabaseManagerStateIsSaving;
	
	BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:databaseFilePath];
	if(success) {
		[self saveDatabaseToSyncFolder];
	}
	state = kURLCollectorDatabaseManagerStateIsIdle;
	TRACE(@"Save success: %d", success);
}

- (void)performSyncIfNeeded
{
	if(![[NSFileManager defaultManager] fileExistsAtPath:defaultSyncDatabasePath()] ||
	   [[NSFileManager defaultManager] contentsEqualAtPath:databaseFilePath andPath:defaultSyncDatabasePath()]) {
		return;
	}
	
	[self stopWatchingSyncFolderForChanges];
	[self mergeChanges];
	[self startWatchingSyncFolderForChanges];
}

- (void)recordChangeWithObject:(URLCollectorNode *)node changeType:(NodeChangeType)changeType
{
	// push these changes to the URLCollectorDatabaseSynchornizer (?)
	[changes addObject:node];
	[changeTypes addObject:[NSNumber numberWithInt:changeType]];
	
	// schedule writing of these changes to the filesystem
}

#pragma mark -
#pragma mark Private Methods

- (void)saveDatabaseToSyncFolder
{
	if(!syncEnabled) {
		return;
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if(![fileManager fileExistsAtPath:defaultSyncPath() isDirectory:&isDirectory] || !isDirectory) {
		ERROR(@"Dropbox folder doesn't exist.");
		return;
	}
	
	NSError *error = nil;
	NSString *syncDatabaseFolderPath = [defaultSyncPath() stringByAppendingPathComponent:@".urlcollector"]; 
	
	isDirectory = NO;
	if(![fileManager fileExistsAtPath:syncDatabaseFolderPath]) {
		if(![fileManager createDirectoryAtPath:syncDatabaseFolderPath withIntermediateDirectories:NO attributes:nil error:&error]) {
			ERROR(@"Unable to create the sync database folder with error <%@>", error);
			return;
		}
	}
	
	[self stopWatchingSyncFolderForChanges];
	
	[fileManager removeItemAtPath:defaultSyncDatabasePath() error:&error];
	if(![fileManager copyItemAtPath:databaseFilePath toPath:defaultSyncDatabasePath() error:&error]) {
		ERROR(@"Unable to copy database file to Dropbox folder with error <%@>", error);
	}
	
	[self startWatchingSyncFolderForChanges];
}

#pragma mark -
#pragma mark Sync Management - NEEDS REFACTORING

- (void)startWatchingSyncFolderForChanges
{
	if(!syncEnabled) {
		return;
	}
	if(databaseFileWatcher) {
		return;
	}
	
//	NSString *syncedDatabasePath = [defaultSyncPath() stringByAppendingPathComponent:@".urlcollector/database.db"];
	databaseFileWatcher = [[GTMFileSystemKQueue alloc] initWithPath:defaultSyncDatabasePath() 
														  forEvents:kGTMFileSystemKQueueAllEvents 
													  acrossReplace:NO 
															 target:self 
															 action:@selector(databaseFileChanged:events:)];
}

- (void)stopWatchingSyncFolderForChanges
{
	[databaseFileWatcher release];
	databaseFileWatcher = nil;
}

// Note: this is as simple as it can be, and *very* flawed
// It's only a proof of concept.
- (void)databaseFileChanged:(GTMFileSystemKQueue *)fskq events:(GTMFileSystemKQueueEvents)events
{
	[self stopWatchingSyncFolderForChanges];
	[self mergeChanges];
	[self startWatchingSyncFolderForChanges];
}

- (void)mergeChanges
{
	ASSERT_STATE(kURLCollectorDatabaseManagerStateIsIdle);

	TRACE(@"Detected a change in the sync folder database file!");
	state = kURLCollectorDatabaseManagerStateIsSyncing;
	
	if([self.delegate respondsToSelector:@selector(databaseManagerWillStartSyncing:)]) {
		[self.delegate databaseManagerWillStartSyncing:self];
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	if(![fileManager removeItemAtPath:databaseFilePath error:&error]) {
		ERROR(@"Unable to remove database file with error <%@>", error);
		goto HandleError;
	}
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
	if(![fileManager copyItemAtPath:defaultSyncDatabasePath() toPath:databaseFilePath error:&error]) {
		ERROR(@"Unable to copy updated sync database with error <%@>!", error);
		goto HandleError;
	}
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
	TRACE(@"Notifying delegate...");
	
	state = kURLCollectorDatabaseManagerStateIsIdle;
	if([self.delegate respondsToSelector:@selector(databaseManagerDidFinishSyncing:)]) {
		[self.delegate databaseManagerDidFinishSyncing:self];
	}
	
	HandleError:
	state = kURLCollectorDatabaseManagerStateIsIdle;
}

@end
