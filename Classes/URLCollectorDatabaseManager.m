//
//  URLCollectorDatabaseManager.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "URLCollectorDatabaseManager.h"
#import "URLCollectorGroup.h"
#import "SKObjectSingleton.h"
#import "GTMFileSystemKQueue.h"

static NSString *defaultSyncPath(void) 
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Dropbox"];
}

@interface URLCollectorDatabaseManager(Private)

- (void)saveDatabaseToSyncFolder;
- (void)startWatchingSyncFolderForChanges;
- (void)stopWatchingSyncFolderForChanges;

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
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (NSArray *)loadData
{
	NSArray *unarchivedObjects =  nil;
	@try {
		unarchivedObjects = [NSKeyedUnarchiver unarchiveObjectWithFile:databaseFilePath];
	}
	@catch (NSException *e) {
		WARN(@"Caught exception while trying to unarchive database. Database file is possibly corrupted.");
		if([[NSFileManager defaultManager] fileExistsAtPath:databaseFilePath]) {
			[[NSFileManager defaultManager] removeItemAtPath:databaseFilePath error:nil];
		}
	}
	
	if(unarchivedObjects) {
		return unarchivedObjects;
	}
	else {
		URLCollectorGroup *inboxGroup = [[URLCollectorGroup alloc] init];
		inboxGroup.name = defaultURLCollectorGroupName();
		NSArray *defaultObject = [NSArray arrayWithObject:inboxGroup];
		[inboxGroup release];
		return defaultObject;
	}
}

- (void)saveData:(NSArray *)data
{
	TRACE(@"***** SAVING CHANGES TO DISK...");
	BOOL success = [NSKeyedArchiver archiveRootObject:data toFile:databaseFilePath];
	if(success) {
		[self saveDatabaseToSyncFolder];
	}
	TRACE(@"Save success: %d", success);
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
	if(![fileManager fileExistsAtPath:[defaultSyncPath() stringByAppendingPathComponent:@".urlcollector"]]) {
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

- (void)databaseFileChanged:(GTMFileSystemKQueue *)fskq events:(GTMFileSystemKQueueEvents)events
{
	TRACE(@"Detected a change in the sync folder database file!");
	// TODO: merge changes into local database and reload it
}

@end
