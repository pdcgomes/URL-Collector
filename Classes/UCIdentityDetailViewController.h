//
//  UCIdentityViewController.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/30/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorElement;

@interface UCIdentityDetailViewController : NSViewController 
{
	NSObject			*delegate;
	URLCollectorElement *element;
}

@property (assign) NSObject *delegate;

- (IBAction)close:(id)sender;
- (id)initWithIdentity:(URLCollectorElement *)element;

@end

@interface NSObject(UCIdentityDetailViewControllerDelegate)

- (void)identityDetailControllerShouldClose:(UCIdentityDetailViewController *)controller;

@end
