//
//  URLCollectorElement.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorElement.h"
#import "URLCollectorContext.h"
#import "URLCollectorContentClassifier.h"
#import "UCImageLoader.h"
#import "NSDateAdditions.h"

@implementation URLCollectorElement

@synthesize data;
@synthesize URL;
@synthesize URLName;
@synthesize icon;
@synthesize context;
@synthesize tags;
@synthesize isUnread;
@synthesize isIconLoaded;
@synthesize classification;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[imageLoader cancel];
	
	SKSafeRelease(data);
	SKSafeRelease(context);
	SKSafeRelease(tags);
	SKSafeRelease(URL);
	SKSafeRelease(URLName);
	SKSafeRelease(icon);
	SKSafeRelease(classification);
	SKSafeRelease(imageLoader);
	
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
	// consider encoding the icon
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
		isIconLoaded = NO;
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
	copy->isIconLoaded = isIconLoaded;
	copy->icon = [icon copy];

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
	[self willChangeValueForKey:@"classification"];
	if(!classification) {
		classification = [[NSMutableDictionary alloc] init];
	}
	
	[classification addEntriesFromDictionary:classificationInfo];
	if([classification containsKey:URLClassificationTitleKey]) {
		self.URLName = [classification objectForKey:URLClassificationTitleKey];
	}
	[self didChangeValueForKey:@"classification"];
}

- (void)loadIconIfNeeded
{
	if(isIconLoaded) {
		[self willChangeValueForKey:@"isIconLoaded"];
		[self didChangeValueForKey:@"isIconLoaded"];
		return;
	}
	
	NSString *iconURL = [self.classification objectForKey:URLClassificationImageKey];
	if(iconURL) {
		imageLoader = [[UCImageLoader alloc] initWithImageURL:iconURL delegate:self];
		[imageLoader load];
	}
}

- (NSString *)stringRepresentation
{
	NSString *template = 
	@"%@\n"				// Title
	@"%@\n"				// URL
	@"%@ %@ %@ %@\n"	// Context and identity
	@"--------------------\n";
	
	NSString *applicationName = SKStringWithFormat2(@"(via %@)", self.context.applicationName);
	return SKStringWithFormat(template, 
							  self.URLName,
							  self.URL,
							  SKSafeString(self.context.interaction),
							  SKSafeString(self.context.contextName),
							  applicationName,
							  [self.context.contextDate formatDate]);
}

- (NSString *)HTMLRepresentation
{
	return nil;
}

#pragma mark -
#pragma mark UCImageLoaderDelegate

- (void)imageLoader:(UCImageLoader *)theImageLoader didFinishLoadingImage:(NSImage *)image
{
	[self willChangeValueForKey:@"isIconLoaded"];
	icon = [image retain];
	isIconLoaded = YES;
	[self didChangeValueForKey:@"isIconLoaded"];
	
	[imageLoader release], imageLoader = nil;
}

- (void)imageLoader:(UCImageLoader *)theImageLoader didFailWithError:(NSError *)error
{
	[self willChangeValueForKey:@"isIconLoaded"];
	[imageLoader release], imageLoader = nil;	
	isIconLoaded = NO;
	[self didChangeValueForKey:@"isIconLoaded"];
}

#pragma -
#pragma mark KVO

+ (NSSet *)keyPathsForValuesAffectingHasChanges
{
	NSMutableSet *keyPaths = [[NSMutableSet alloc] initWithSet:[super keyPathsForValuesAffectingValueForKey:@"hasChanges"]];
	[keyPaths unionSet:[NSSet setWithObjects:
						@"URL",
						@"URLName",
						@"tags",
						@"context",
						@"classification",
						@"isUnread",
						nil]];
	NSSet *affectingKeyPaths = [NSSet setWithSet:keyPaths];
	[keyPaths release];
	return affectingKeyPaths;
}

@end
