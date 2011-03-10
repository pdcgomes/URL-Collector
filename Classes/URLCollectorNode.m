//
//  URLCollectorNode.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorNode.h"

@implementation URLCollectorNode

@synthesize name = nodeName;
@synthesize parentNode;
@synthesize children;
@synthesize isLeafNode;
@synthesize createDate;
@synthesize sortOrder;
@dynamic numberOfChildren;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	SKSafeRelease(nodeName);
	SKSafeRelease(createDate);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (NSUInteger)numberOfChildren
{
	return [children count];
}


@end
