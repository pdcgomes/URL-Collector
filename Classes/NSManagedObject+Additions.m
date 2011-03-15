//
//  NSManagedObjectAdditions.m
//  WideScope_Farmacias_iPhone
//
//  Created by Pedro Gomes on 11/4/09.
//  Copyright 2009 SAPO. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@interface NSManagedObject(AdditionsPrivate)

- (id)duplicate:(NSMutableDictionary *)excludeRelationships;
- (id)duplicateRelationship:(NSRelationshipDescription *)relationship excludeRelationships:(NSMutableDictionary *)excludeRelationships;

@end

@implementation NSManagedObject(Additions)

- (BOOL)trySetProperty:(SEL)propertySetter withValue:(NSString *)value
{
	BOOL success = NO;
	
	if(!IsEmptyString(value)) {
		[self performSelector:propertySetter withObject:value];
		success = YES;
	}
	
	return success;
}

- (BOOL)trySetProperty:(SEL)propertySetter withValue:(id)value transform:(SEL)transformSelector
{
	BOOL success = NO;
	
	if(![value isKindOfClass:[NSString class]]) {
		return NO;
	}
	
	if(!IsEmptyString(value)) {
		[self performSelector:propertySetter withObject:(id)[value performSelector:transformSelector]];
		success = YES;
	}
	
	return success;
}

- (BOOL)trySetPropertyForKey:(NSString *)keyPath withValue:(id)value transform:(SEL)transformSelector
{
	if(![value isKindOfClass:[NSString class]]) {
		return NO;
	}
	if(IsEmptyString(value)) {
		return NO;
	}
	if(![value respondsToSelector:transformSelector]) {
		return NO;
	}
	
	[self setValue:[value performSelector:transformSelector] forKey:keyPath];
	return YES;
}

- (BOOL)trySetNumberProperty:(SEL)selector withValue:(NSString *)value formatter:(NSNumberFormatter *)numberFormatter
{
	if(![self isNilValue:value]) {
		[self performSelector:selector withObject:[numberFormatter numberFromString:value]];
		return YES;
	}
	return NO;
}

- (BOOL)isNilValue:(id)value
{
	return [value isKindOfClass:[NSDictionary class]] && CFDictionaryContainsKey((CFDictionaryRef)value, @"nil");
}

- (NSManagedObject *)duplicate
{
	NSMutableDictionary *excludeRelationships = [[NSMutableDictionary alloc] init];
	NSManagedObject *duplicate = [self duplicate:excludeRelationships];
	[excludeRelationships release];
	return duplicate;
}

#pragma mark -
#pragma mark Private Methods

- (id)duplicate:(NSMutableDictionary *)excludeRelationships
{
	NSEntityDescription *entityDescription = [self entity];
	NSMutableDictionary *propertyValueDict = [[NSMutableDictionary alloc] init];
	
	for(NSPropertyDescription *propertyDescription in [entityDescription properties]) {
		NSString *propertyName = [propertyDescription name];
		if([propertyDescription isKindOfClass:[NSAttributeDescription class]]) {
			if([self valueForKey:propertyName]) {
				[propertyValueDict setObject:[self valueForKey:propertyName] forKey:propertyName];
			}
		}
		else if([propertyDescription isKindOfClass:[NSRelationshipDescription class]]) {
			NSData *versionHash = [propertyDescription versionHash];
			id relationship = nil;
			if(CFDictionaryContainsKey((CFDictionaryRef)excludeRelationships, versionHash)) {
				TRACE(@"Relationship was previously duplicated. Bypassing...");
				relationship = [excludeRelationships objectForKey:versionHash]; // Fetch the duplicate entity associated with the relationship
			}
			else {
				[excludeRelationships setObject:[NSNull null] forKey:versionHash];
				relationship = [self duplicateRelationship:(NSRelationshipDescription *)propertyDescription excludeRelationships:excludeRelationships];
				[excludeRelationships setObject:relationship forKey:versionHash];
			}
			[propertyValueDict setObject:relationship forKey:propertyName];
		}
	}
	
	NSManagedObject *duplicateEntity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) 
																	 inManagedObjectContext:[self managedObjectContext]];
	[duplicateEntity setValuesForKeysWithDictionary:propertyValueDict];
	[propertyValueDict release];
	
	return duplicateEntity;
	
}

- (id)duplicateRelationship:(NSRelationshipDescription *)relationship excludeRelationships:(NSMutableDictionary *)excludeRelationships
{
	id duplicate = nil;
	NSString *propertyName = [relationship name];
	
	TRACE(@"Duplicating relationship <%@>", [relationship name]);
	if([relationship isToMany]) {
		NSMutableSet *set = [NSMutableSet set];
		for(NSManagedObject *relationship in [self valueForKey:propertyName]) {
			[set addObject:[relationship duplicate:excludeRelationships]];
		}
		duplicate = set;
	}
	else {
		NSManagedObject *relationship = [self valueForKey:propertyName];
		duplicate = [relationship duplicate:excludeRelationships];
	}
	return duplicate;
}

@end
