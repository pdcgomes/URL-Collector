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

@interface URLCollectorDataSource : NSObject <NSOutlineViewDataSource>
{
	NSManagedObjectContext		*managedObjectContext;
	
	NSMutableArray				*urlCollectorElements;
	NSMutableArray				*selectedElements;
	
	BOOL						hasPendingChanges;
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *urlCollectorElements;
@property (nonatomic, retain) NSMutableArray *selectedElements;

- (void)addGroup:(URLCollectorGroup *)group;
- (void)addGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index;

- (void)addElement:(URLCollectorElement *)element;
- (void)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group;
- (void)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group atIndex:(NSInteger)index;

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

