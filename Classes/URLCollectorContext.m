//
//  URLCollectorElementSource.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorContext.h"

@implementation URLCollectorContext

@synthesize contextName;
@synthesize contextURL;
@synthesize contextIdentity;
@synthesize contextApplication;

@dynamic applicationName;
@dynamic applicationBundleIdentifier;
@dynamic applicationIcon;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	SKSafeRelease(contextName);	
	SKSafeRelease(contextURL);
	SKSafeRelease(contextIdentity);
	SKSafeRelease(contextApplication);
	
	[super dealloc];
}

- (id)initWithIdentity:(NSDictionary *)identityInfo fromApplication:(NSDictionary *)applicationInfo
{
	if((self = [super init])) {
		
	}
	return self;
}

@end
