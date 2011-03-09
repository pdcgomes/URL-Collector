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
@synthesize isLeafNode;
@synthesize createDate;
@synthesize sortOrder;

- (void)dealloc
{
	SKSafeRelease(nodeName);
	SKSafeRelease(createDate);
	
	[super dealloc];
}

@end
