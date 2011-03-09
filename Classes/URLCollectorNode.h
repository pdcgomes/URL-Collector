//
//  URLCollectorNode.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface URLCollectorNode : NSObject 
{
	NSString			*nodeName;
	URLCollectorNode	*parentNode;
	BOOL				isLeafNode;

	NSDate				*createDate;	
	NSUInteger			sortOrder;

}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) URLCollectorNode *parentNode;
@property (nonatomic, assign) BOOL isLeafNode;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, assign) NSUInteger sortOrder;

@end
