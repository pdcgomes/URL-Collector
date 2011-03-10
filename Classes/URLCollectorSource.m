//
//  URLCollectorElementSource.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorSource.h"

@implementation URLCollectorSource

@synthesize sourceName;
@synthesize sourceURL;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	SKSafeRelease(sourceName);	
	SKSafeRelease(sourceURL);
	
	[super dealloc];
}

- (id)initWithPerson:(NSDictionary *)personInfo
{
	if((self = [super init])) {
		
	}
	return self;
}

- (id)initWithApplication:(NSDictionary *)applicationInfo;
{
	if((self = [super init])) {
		
	}
	return self;
}

@end
