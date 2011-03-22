//
//  URLCollectorNode.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorNode.h"

@implementation URLCollectorNode

@synthesize nodeUUID;
@synthesize name = nodeName;
@synthesize parent;
@synthesize children;
@synthesize isLeafNode;
@synthesize isLocked;
@synthesize createDate;
@synthesize sortOrder;
@dynamic contentsHash;
@dynamic numberOfChildren;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	SKSafeRelease(nodeUUID);
	SKSafeRelease(nodeName);
	
	SKSafeRelease(createDate);
	SKSafeRelease(children);
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
		nodeUUID = [(NSString *)uuidString copy];
		createDate = [[NSDate date] retain];
		CFRelease(uuidString);
		CFRelease(uuid);
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:nodeUUID forKey:@"nodeUUID"];
	[aCoder encodeObject:nodeName forKey:@"nodeName"];
	[aCoder encodeObject:children forKey:@"children"];
	[aCoder encodeBool:isLeafNode forKey:@"isLeafNode"];
	[aCoder encodeBool:isLocked forKey:@"isLocked"];
	[aCoder encodeObject:createDate forKey:@"createDate"];
	[aCoder encodeInt:sortOrder forKey:@"sortOrder"];
	[aCoder encodeObject:self.contentsHash forKey:@"contentsHash"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super init])) {
		nodeUUID = [[aDecoder decodeObjectForKey:@"nodeUUID"] copy];
		nodeName = [[aDecoder decodeObjectForKey:@"nodeName"] copy];
		children = [[aDecoder decodeObjectForKey:@"children"] retain];
		for(URLCollectorNode *child in children) {
			[child setParent:self];
		}
		
		isLeafNode		= [aDecoder decodeBoolForKey:@"isLeafNode"];
		isLocked		= [aDecoder decodeBoolForKey:@"isLocked"];
		createDate		= [[aDecoder decodeObjectForKey:@"createDate"] retain];
		sortOrder		= [aDecoder decodeIntForKey:@"sortOrder"];
	}
	return self;
}

#pragma mark -
#pragma mark Properties

- (NSUInteger)numberOfChildren
{
	return [children count];
}

- (NSString *)contentsHash
{
	return nil;
}

@end
