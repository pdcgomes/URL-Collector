//
//  URLCollectorDataSource.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorGroup;
@class URLCollectorElement;
@class URLCollectorDatabaseManager;

@interface URLCollectorDataSource : NSObject <NSOutlineViewDataSource>
{
	__weak NSOutlineView		*outlineView_; // weak reference
	NSManagedObjectContext		*managedObjectContext;
	
	NSMutableArray				*urlCollectorElements;
	NSMutableArray				*selectedElements;
	
	NSMutableDictionary			*elementIndex; // URL -> IndexPath
	
	BOOL						hasPendingChanges;
	
	NSOperationQueue			*operationQueue;
	URLCollectorDatabaseManager *databaseManager;
	
	NSPredicate					*predicate;
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) NSOutlineView *outlineView;
@property (nonatomic, retain) NSMutableArray *urlCollectorElements;
@property (nonatomic, retain) NSMutableArray *selectedElements;
@property (nonatomic, retain) NSPredicate *predicate;

- (void)addURLToInbox:(NSString *)URL;
- (void)addURL:(NSString *)URL toGroup:(URLCollectorGroup *)group;

- (void)addGroup:(URLCollectorGroup *)group;
- (void)addGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index;

- (void)addElement:(URLCollectorElement *)element;
- (BOOL)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group;
- (BOOL)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index;

- (void)removeGroup:(URLCollectorGroup *)group;
- (void)removeGroup:(URLCollectorGroup *)group removeChildren:(BOOL)shouldRemoveChildren; // If shouldRemoveChildren == NO, child elements are moved to the default "Inbox" group automatically

- (void)removeElement:(URLCollectorElement *)element;
- (void)removeElement:(URLCollectorElement *)element fromGroup:(URLCollectorGroup *)group;

- (void)moveGroup:(URLCollectorGroup *)group toIndex:(NSInteger)index;
- (void)moveElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group;

- (void)saveChanges;

@end

extern NSString *column1Identifier;
extern NSString *column2Identifier;

extern NSString *const NSPasteboardTypeURLCollectorElement;

