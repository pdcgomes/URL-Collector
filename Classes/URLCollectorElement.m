//
//  URLCollectorElement.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorElement.h"
#import "URLCollectorContext.h"

@implementation URLCollectorElement

@synthesize data;
@synthesize elementURL;
@synthesize parentGroup;
@synthesize source;
@synthesize tags;
@synthesize isUnread;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	SKSafeRelease(data);
	SKSafeRelease(source);
	SKSafeRelease(tags);
	SKSafeRelease(elementURL);
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:data forKey:@"data"];
	[aCoder encodeObject:elementURL forKey:@"elementURL"];
//	[aCoder encodeObject:parentGroup forKey:@"parentGroup"];
	[aCoder encodeObject:source forKey:@"source"];
	[aCoder encodeObject:tags forKey:@"tags"];
	[aCoder encodeBool:isUnread forKey:@"isUnread"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])) {
		data = [[aDecoder decodeObjectForKey:@"data"] retain];
		elementURL = [[aDecoder decodeObjectForKey:@"elementURL"] copy];
//		parentGroup = [aDecoder decodeObjectForKey:@"parentGroup"]; // This is probably wrong right here...
		source = [[aDecoder decodeObjectForKey:@"source"] retain];
		tags = [[aDecoder decodeObjectForKey:@"tags"] retain];
		isUnread = [aDecoder decodeBoolForKey:@"isUnread"];
	}
	return self;
}

#pragma mark -
#pragma mark Properties

- (BOOL)isLeafNode
{
	return YES;
}

@end
