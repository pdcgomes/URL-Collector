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
#import "SKObjectSingleton.h"
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

@end

@implementation URLCollectorDatabaseManager

@synthesize delegate;

#pragma mark -
#pragma mark Dealloc and Initialization

//SK_OBJECT_SINGLETON_BOILERPLATE(URLCollectorDatabaseManager, sharedInstance);

- (void)dealloc
{
	[self stopWatchingSyncFolderForChanges];
	self.delegate = nil;
	
	[databaseFilePath release];
	[databaseFileWatcher release];
	[super dealloc];
}

- (id)initWithDatabaseFilePath:(NSString *)theDatabaseFilePath
{
	if((self = [super init])) {
		databaseFilePath = [theDatabaseFilePath copy];
		syncEnabled = YES;
		state = kURLCollectorDatabaseManagerStateIsIdle;
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
	}
	@catch (NSException *e) {
		WARN(@"Caught exception while trying to unarchive database. Database file is possibly corrupted.");
		if([[NSFileManager defaultManager] fileExistsAtPath:databaseFilePath]) {
			[[NSFileManager defaultManager] removeItemAtPath:databaseFilePath error:nil];
		}
	}
	if(!loadedObjects) {
		URLCollectorGroup *inboxGroup = [[URLCollectorGroup alloc] init];
		inboxGroup.name = defaultURLCollectorGroupName();
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
	
	NSString *syncDatabaseFilePath = [syncDatabaseFolderPath stringByAppendingPathComponent:@"database.db"];
	[fileManager removeItemAtPath:syncDatabaseFilePath error:&error];
	if(![fileManager copyItemAtPath:databaseFilePath toPath:syncDatabaseFilePath error:&error]) {
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
	
	NSString *syncedDatabasePath = [defaultSyncPath() stringByAppendingPathComponent:@".urlcollector/database.db"];
	databaseFileWatcher = [[GTMFileSystemKQueue alloc] initWithPath:syncedDatabasePath 
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
	NSString *syncedDatabasePath = [defaultSyncPath() stringByAppendingPathComponent:@".urlcollector/database.db"];
	
	NSError *error = nil;
	if(![fileManager removeItemAtPath:databaseFilePath error:&error]) {
		ERROR(@"Unable to remove database file with error <%@>", error);
		goto HandleError;
	}
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
	if(![fileManager copyItemAtPath:syncedDatabasePath toPath:databaseFilePath error:&error]) {
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
