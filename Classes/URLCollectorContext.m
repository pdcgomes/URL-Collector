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
@synthesize interaction;

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
	SKSafeRelease(interaction);
	
	[super dealloc];
}

- (id)initWithIdentity:(NSDictionary *)identityInfo fromApplication:(NSDictionary *)applicationInfo
{
	if((self = [super init])) {
		contextName = [[identityInfo objectForKey:@"identityName"] copy];
		
		NSMutableString *interactionString = [[NSMutableString alloc] initWithString:@""];
		[interactionString appendString:SKSafeString([identityInfo objectForKey:@"interactionType"])];
		if([interactionString length] > 0 && [[identityInfo objectForKey:@"interactionPreposition"] length] > 0) {
			[interactionString appendFormat:@" %@", SKSafeString([identityInfo objectForKey:@"interactionPreposition"])];
		}
		interaction = [[NSString alloc] initWithString:interactionString];
		[interactionString release];
		
		NSMutableDictionary *fullApplicationInfo = [[NSMutableDictionary alloc] initWithDictionary:applicationInfo];
		[fullApplicationInfo removeObjectForKey:@"NSWorkspaceApplicationKey"]; // Removal of elements that don't support NSCoding or that we don't want/need to support
		contextApplication = [[NSDictionary alloc] initWithDictionary:fullApplicationInfo];
		[fullApplicationInfo release];
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
	[aCoder encodeObject:interaction forKey:@"interaction"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init])) {
		contextName		= [[aDecoder decodeObjectForKey:@"contextName"] copy];
		contextURL		= [[aDecoder decodeObjectForKey:@"contextURL"] copy];
		interaction		= [[aDecoder decodeObjectForKey:@"interaction"] copy];
		
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
	return [contextName length] > 0 ?  
	SKStringWithFormat(@"%@ %@ (via %@)", SKSafeString(interaction), contextName, [self applicationName]) :
	SKStringWithFormat(@"(via %@)", [self applicationName]);
}

@end
