//
//  URLCollectorNode.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface URLCollectorNode : NSObject <NSCoding>
{
	NSString			*nodeName;
	URLCollectorNode	*parentNode;
	NSMutableArray		*children;
	BOOL				isLeafNode;
	BOOL				isLocked;

	NSDate				*createDate;	
	NSUInteger			sortOrder;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) URLCollectorNode *parentNode;
@property (nonatomic, retain) NSMutableArray *children;
@property (nonatomic, readonly) NSUInteger numberOfChildren;

@property (nonatomic, assign) BOOL isLeafNode;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, assign) NSUInteger sortOrder;

@end
