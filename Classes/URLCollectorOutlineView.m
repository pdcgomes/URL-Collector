//
//  URLCollectorOutlineView.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/10/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorOutlineView.h"

@implementation URLCollectorOutlineView

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[super dealloc];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, NSPasteboardTypeHTML, NSPasteboardTypeRTF, nil]];
}

#pragma mark -
#pragma mark Drag and Drop support

@end
