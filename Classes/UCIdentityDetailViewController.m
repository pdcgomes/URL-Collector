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

@synthesize delegate;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	self.delegate = nil;
	
	[element release];
	[super dealloc];
}

- (id)initWithIdentity:(URLCollectorElement *)theElement
{
	if((self = [super initWithNibName:@"IdentityDetailViewS" bundle:nil])) {
		element = [theElement retain];
		[self setRepresentedObject:theElement];
	}
	return self;
}

- (void)awakeFromNib
{
	TRACEMARK;
}

#pragma mark -
#pragma mark IBAction

- (IBAction)close:(id)sender
{
	if([self.delegate respondsToSelector:@selector(identityDetailControllerShouldClose:)]) {
		[self.delegate identityDetailControllerShouldClose:self];
	}
}

@end
