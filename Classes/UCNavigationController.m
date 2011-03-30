//
//  UCNavigationController.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/29/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "UCNavigationController.h"

@implementation UCNavigationController

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[viewControllers release];
	[super dealloc];
}

- (id)initWithRootViewController:(NSViewController *)viewController
{
	if((self = [super init])) {
		viewControllers = [[NSMutableArray alloc] initWithObjects:viewController, nil];
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated
{
	[viewControllers addObject:viewController];
}

- (void)popViewControllerAnimated:(BOOL)animated
{
	[viewControllers removeLastObject];
}

@end
