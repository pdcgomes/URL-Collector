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

@synthesize name;
@synthesize elementURL;
@synthesize parentGroup;
@synthesize source;
@synthesize tags;
@synthesize dateAdded;
@synthesize isUnread;
@dynamic isLeafNode;

- (void)dealloc
{
	SKSafeRelease(source);
	SKSafeRelease(tags);
	SKSafeRelease(dateAdded);
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
