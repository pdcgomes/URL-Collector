//
//  URLCollectorGroup.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorGroup.h"
#import "URLCollectorElement.h"
#import "URLCollectorNode.h"

@implementation URLCollectorGroup

@synthesize groupColor;
@synthesize groupImage;
//@synthesize parentGroup;

- (void)dealloc
{
	SKSafeRelease(groupColor);
	SKSafeRelease(groupImage);
//	SKSafeRelease(children);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (BOOL)isLeafNode
{
	return NO;
}

#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:groupColor forKey:@"groupColor"];
	[aCoder encodeObject:groupImage forKey:@"groupImage"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])) {
		groupColor = [[aDecoder decodeObjectForKey:@"groupColor"] copy];
		groupImage = [[aDecoder decodeObjectForKey:@"groupImage"] retain];
	}
	return self;
}

#pragma mark -
#pragma mark Properties

- (NSString *)name
{
	return [children count] > 0 ? SKStringWithFormat(@"%@ (%d)", nodeName, [children count]) : nodeName;
}

#pragma mark -
#pragma mark Public Methods

- (void)add:(URLCollectorElement *)element
{
	[self add:element atIndex:-1];
}

- (void)add:(URLCollectorElement *)element atIndex:(NSInteger)index
{
	[element retain];	
	
	if(!children) {
		children = [[NSMutableArray alloc] initWithCapacity:1];
	}
	if(element.parent == self) {
		[self moveChild:element toIndex:index];
		return;
	}
	else if(element.parent != nil) {
		[(URLCollectorGroup *)element.parent remove:element];
	}
	[element setParent:self];
	
	[self willChangeValueForKey:@"children"];
	
	if(index >= 0) {
		if(index <= [children count]) {
			[children insertObject:element atIndex:index];
			[element setSortOrder:index];
		}
		else {
			[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.InvalidChildIndexException" reason:@"" userInfo:nil] raise];
		}
	}
	else {
		[children addObject:element];
		element.sortOrder = [children count] - 1;
	}
	
	[self didChangeValueForKey:@"children"];
	
	[element release];
}

- (void)moveChild:(URLCollectorElement *)element toIndex:(NSInteger)newIndex
{
	NSInteger oldIndex = [children indexOfObject:element];
	if(element.parent != self || NSNotFound == oldIndex) {
		[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.InvalidParentNodeException" reason:@"Attempted to move an element that's not a child of the current node" userInfo:nil] raise];
	}
	
	if(newIndex == oldIndex) {
		return;
	}
	
	[element retain];
	[self willChangeValueForKey:@"children"];
	
	if(newIndex == 0) {
		[children removeObjectAtIndex:oldIndex];
		[children insertObject:element atIndex:newIndex];
	}
	else if(newIndex > oldIndex) {
		[children insertObject:element atIndex:newIndex];
		[children removeObjectAtIndex:oldIndex];
	}
	else {
		[children removeObjectAtIndex:oldIndex];
		[children insertObject:element atIndex:newIndex];
	}
	element.sortOrder = newIndex;

	[self didChangeValueForKey:@"children"];
	[element release];
}

- (void)removeAllChildren
{
	[self.children makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
	[self.children removeAllObjects];
}

- (void)remove:(URLCollectorElement *)element
{
	NSInteger indexOfObject = [children indexOfObject:element];
	if(NSNotFound == indexOfObject) {
		FATAL(@"Object not found.");
		[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.ChildNotFoundException" reason:@"" userInfo:nil] raise];
	}
	[children removeObjectAtIndex:indexOfObject];
	[element setParent:nil];
}

#pragma mark -
#pragma mark KVO

// Automatically notifies of count changes when "children" changes
+ (NSSet *)keyPathsForValuesAffectingNumberOfChildren
{
	return [NSSet setWithObject:@"children"];
}

@end
