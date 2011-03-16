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
		contextName = [[identityInfo objectForKey:@"identityName"] copy];
		
		NSMutableDictionary *tmpApplicationInfo = [[NSMutableDictionary alloc] initWithDictionary:applicationInfo];
		[tmpApplicationInfo removeObjectForKey:@"NSWorkspaceApplicationKey"];
		contextApplication = [[NSDictionary alloc] initWithDictionary:tmpApplicationInfo];
		[tmpApplicationInfo release];
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:contextName forKey:@"contextName"];
	[aCoder encodeObject:contextURL forKey:@"contextURL"];
	//	[aCoder encodeObject:contextIdentity forKey:@"contextIdentity"];
	[aCoder encodeObject:contextApplication forKey:@"contextApplication"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init])) {
		contextName = [[aDecoder decodeObjectForKey:@"contextName"] copy];
		contextURL	= [[aDecoder decodeObjectForKey:@"contextURL"] copy];
		//		contextIdentity = [[aDecoder decodeObjectForKey:@""] retain];
		contextApplication = [[aDecoder decodeObjectForKey:@"contextApplication"] retain];
	}
	return self;
}

#pragma mark -
#pragma mark Dynamic properties

- (NSString *)applicationName
{
	return [contextApplication objectForKey:@"NSApplicationName"];
}

- (NSString *)applicationBundleIdentifier
{
	return [contextApplication objectForKey:@"NSApplicationBundleIdentifier"];
}

- (NSImage *)applicationIcon
{
	NSNumber *pid = [contextApplication objectForKey:@"NSApplicationProcessIdentifier"];
	NSRunningApplication *application = [NSRunningApplication runningApplicationWithProcessIdentifier:[pid integerValue]];
	return [application icon];
}

- (NSString *)contextInfoLine
{
	return SKStringWithFormat(@"Sent by %@ (via %@)", contextName, [self applicationName]);
	return nil;
}

@end
