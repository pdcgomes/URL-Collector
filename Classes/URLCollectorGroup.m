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
@synthesize parentGroup;

- (void)dealloc
{
	SKSafeRelease(groupColor);
	SKSafeRelease(children);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

- (BOOL)isLeafNode
{
	return NO;
}

#pragma mark -
#pragma mark Public Methods

- (void)add:(URLCollectorElement *)element
{
	if(!children) {
		children = [[NSMutableArray alloc] initWithCapacity:1];
	}
	[element setParentGroup:self];
	
	[self willChangeValueForKey:@"children"];
	[children addObject:element];
	[self didChangeValueForKey:@"children"];
}

- (void)remove:(URLCollectorElement *)element
{
	NSInteger indexOfObject = [children indexOfObject:element];
	if(NSNotFound == indexOfObject) {
		FATAL(@"Object not found.");
		[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.ChildNotFoundException" reason:@"" userInfo:nil] raise];
	}
	[children removeObjectAtIndex:indexOfObject];
}

#pragma mark -
#pragma mark KVO

// Automatically notifies of count changes when "children" changes
+ (NSSet *)keyPathsForValuesAffectingNumberOfChildren
{
	TRACE(@"");
	return [NSSet setWithObject:@"children"];
}

@end
