//
//  URLCollectorElement.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorElement.h"
#import "URLCollectorContentClassifier.h"

@implementation URLCollectorElement

@synthesize data;
@synthesize URL;
@synthesize URLName;
@synthesize context;
@synthesize tags;
@synthesize isUnread;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	SKSafeRelease(data);
	SKSafeRelease(context);
	SKSafeRelease(tags);
	SKSafeRelease(URL);
	SKSafeRelease(URLName);
	SKSafeRelease(classification);
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:data forKey:@"data"];
	[aCoder encodeObject:URL forKey:@"URL"];
	[aCoder encodeObject:URLName forKey:@"URLName"];
	[aCoder encodeObject:context forKey:@"source"];
	[aCoder encodeObject:tags forKey:@"tags"];
	[aCoder encodeBool:isUnread forKey:@"isUnread"];
	[aCoder encodeObject:context forKey:@"context"];
	[aCoder encodeObject:classification forKey:@"classification"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])) {
		data		= [[aDecoder decodeObjectForKey:@"data"] retain];
		URL			= [[aDecoder decodeObjectForKey:@"URL"] copy];
		URLName		= [[aDecoder decodeObjectForKey:@"URLName"] copy];	
		context		= [[aDecoder decodeObjectForKey:@"source"] retain];
		tags		= [[aDecoder decodeObjectForKey:@"tags"] retain];
		isUnread	= [aDecoder decodeBoolForKey:@"isUnread"];
		context		= [[aDecoder decodeObjectForKey:@"context"] retain];
		classification = [[aDecoder decodeObjectForKey:@"classification"] retain];
	}
	return self;
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	URLCollectorElement *copy = [[[self class] alloc] init];
	copy->URL = [URL copy];
	copy->URLName = [URLName copy];
	copy->tags = [tags copy];
	
	copy->context = [context copy];
	copy->classification = [classification copy];	
	copy->isUnread = isUnread;

	return copy;
}

- (BOOL)isEqual:(id)object
{
	return [object isKindOfClass:[self class]] &&  [[(URLCollectorElement *)object URL] isEqual:[self URL]];
}

- (NSUInteger)hash
{
	return [self.URL hash];
}

#pragma mark -
#pragma mark Properties

- (BOOL)isLeafNode
{
	return YES;
}

//- (NSString *)name
//{
//	return SKStringWithFormat(@"%@\n"
//							  @"%@", URL, [self.context contextInfoLine]);
//}

- (NSString *)contentsHash
{
	// hash parentGroup UUID + URL + sortOrder
	return nil;
}

#pragma mark -
#pragma mark Public Methods

- (void)updateClassification:(NSDictionary *)classificationInfo
{
	if(!classification) {
		classification = [[NSMutableDictionary alloc] init];
	}
	
	[classification addEntriesFromDictionary:classificationInfo];
	if([classification containsKey:URLClassificationTitleKey]) {
		self.URLName = [classification objectForKey:URLClassificationTitleKey];
	}
}

@end
