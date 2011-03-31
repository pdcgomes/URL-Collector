//
//  UCIdentityViewController.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/30/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "UCIdentityDetailViewController.h"
#import "URLCollectorContextIdentity.h"

@implementation UCIdentityDetailViewController

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[identity release];
	[super dealloc];
}

- (id)initWithIdentity:(URLCollectorContextIdentity *)theIdentity
{
	if((self = [super initWithNibName:@"IdentityDetailView" bundle:nil])) {
		[self setRepresentedObject:theIdentity];
		identity = [theIdentity retain];
	}
	return self;
}

- (void)awakeFromNib
{
	
}

@end
