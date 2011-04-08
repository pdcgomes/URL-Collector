//
//  StatusItemView.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatusItemDraggingDestinationView : NSImageView 
{
	NSStatusItem	*statusItem;
	BOOL			isMouseDown;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@end
