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
	NSMutableArray				*urlCollectorElements;
	NSMutableArray				*selectedElements;
}

- (void)addGroup:(URLCollectorGroup *)group;
- (void)addElement:(URLCollectorElement *)element;
- (void)addElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group;

- (void)removeGroup:(URLCollectorGroup *)group;
- (void)removeElement:(URLCollectorElement *)element;
- (void)removeElement:(URLCollectorElement *)element fromGroup:(URLCollectorGroup *)group;

- (void)moveElement:(URLCollectorElement *)element toGroup:(URLCollectorGroup *)group;

@end

extern NSString *column1Identifier;
extern NSString *column2Identifier;

