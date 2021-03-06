//
//  URLCollectorNode.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface URLCollectorNode : NSObject <NSCoding, NSCopying>
{
	NSString			*nodeUUID;
	NSString			*nodeName;
	
	URLCollectorNode	*parent;
	NSMutableArray		*children;
	BOOL				isLeafNode;
	BOOL				isLocked;

	NSDate				*createDate;	
	NSUInteger			sortOrder;
	
	BOOL				hasChanges;
	
	NSPredicate			*predicate;
}

@property (nonatomic, readonly) NSString *nodeUUID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) URLCollectorNode *parent;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, readonly) NSUInteger numberOfChildren;

@property (nonatomic, assign) BOOL isLeafNode;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, assign) NSUInteger sortOrder;

@property (nonatomic, readonly) NSString *contentsHash;
@property (nonatomic, readonly) BOOL hasChanges;

@property (nonatomic, retain) NSPredicate *predicate;
@property (nonatomic, readonly) NSString *formattedDate;
@property (nonatomic, readonly) NSString *formattedNumberOfChildren;

@end
