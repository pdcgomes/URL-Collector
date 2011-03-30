//
//  URLCollectorElementCell.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BWHyperlinkButtonCell;

@interface URLCollectorElementCell : NSActionCell 
{
	NSTextFieldCell *titleCell;
	NSTextFieldCell	*urlCell;
	NSTextFieldCell	*interactionTypeCell;
	NSTextFieldCell	*extraInfoCell;
	NSButtonCell	*identityButtonCell;
	
	NSRect			titleCellFrame;
	NSRect			urlCellFrame;
	NSRect			interactionCellFrame;
	NSRect			extraInfoCellFrame;
	NSRect			identityButtonCellFrame;
}

@end
