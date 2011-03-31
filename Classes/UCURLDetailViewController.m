//
//  UCURLDetailViewController.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/30/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "UCURLDetailViewController.h"
#import "URLCollectorElement.h"

@implementation UCURLDetailViewController

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[super dealloc];
}

- (id)initWithElement:(URLCollectorElement *)theElement
{
	if((self = [super initWithNibName:@"URLDetailView" bundle:nil])) {
		[self setRepresentedObject:theElement];
	}
	return self;
}

- (void)awakeFromNib
{
	
}

@end
