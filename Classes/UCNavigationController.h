//
//  UCNavigationController.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/29/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UCNavigationController : NSObject 
{
	NSMutableArray	*viewControllers;
}

- (id)initWithRootViewController:(NSViewController *)viewController;

- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

@end
