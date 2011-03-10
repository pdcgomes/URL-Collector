//
//  URLCollectorElement.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorElement.h"
#import "URLCollectorSource.h"

@implementation URLCollectorElement

@synthesize data;
@synthesize name;
@synthesize elementURL;
@synthesize parentGroup;
@synthesize source;
@synthesize tags;
@synthesize isUnread;
@dynamic isLeafNode;

- (void)dealloc
{
	SKSafeRelease(data);
	SKSafeRelease(source);
	SKSafeRelease(tags);
	SKSafeRelease(elementURL);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (BOOL)isLeafNode
{
	return YES;
}

@end
