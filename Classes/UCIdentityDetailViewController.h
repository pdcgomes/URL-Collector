//
//  UCIdentityViewController.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/30/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorContextIdentity;

@interface UCIdentityDetailViewController : NSViewController 
{
	URLCollectorContextIdentity *identity;
}

- (id)initWithIdentity:(URLCollectorContextIdentity *)identity;

@end
