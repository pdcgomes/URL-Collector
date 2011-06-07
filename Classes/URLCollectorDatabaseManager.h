//
//  URLCollectorDatabaseManager.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorDatabaseManager;

@protocol URLCollectorDatabaseManagerDelegate <NSObject>

@optional

- (void)databaseManager:(URLCollectorDatabaseManager *)database didLoadData:(id)data;

- (void)databaseManagerWillStartSavingData:(URLCollectorDatabaseManager *)database;
- (void)databaseManagerDidStartSavingData:(URLCollectorDatabaseManager *)database;
- (void)databaseManagerDidFinishSavingData:(URLCollectorDatabaseManager *)database;

- (void)databaseManagerNeedsSyncing:(URLCollectorDatabaseManager *)database;
- (void)databaseManagerWillStartSyncing:(URLCollectorDatabaseManager *)database;
- (void)databaseManagerDidStartSyncing:(URLCollectorDatabaseManager *)database;
- (void)databaseManagerDidFinishSyncing:(URLCollectorDatabaseManager *)database;

@end

typedef enum {
	NodeChangeTypeInsert = 0,
	NodeChangeTypeUpdate,
	NodeChangeTypeDelete,
} NodeChangeType;

@class GTMFileSystemKQueue;

@interface URLCollectorDatabaseManager : NSObject 
{
	NSString											*databaseFilePath;
	GTMFileSystemKQueue									*databaseFileWatcher;
	NSObject<URLCollectorDatabaseManagerDelegate>		*delegate;

	NSInteger	state;
	BOOL		syncEnabled;
	
	NSMutableArray										*changes;
	NSMutableArray										*changeTypes;
}

@property (nonatomic, assign) NSObject<URLCollectorDatabaseManagerDelegate> *delegate;

- (id)initWithDatabaseFilePath:(NSString *)databaseFilePath;

- (NSArray *)loadData;
- (void)saveData:(NSArray *)data;

- (void)performSyncIfNeeded;
//- (void)loadDataAsync;
//- (void)saveDataAsync(id)data;
//
//- (void)enableSyncing;
//- (void)disableSyncing;

// This records changes for a given object
// 0 - insert
// 1 - update
// 2 - delete

@end
