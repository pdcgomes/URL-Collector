//
//  URLCollectorGroupCell.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorGroupCell.h"
#import "URLCollectorGroup.h"

@interface URLCollectorGroupCell(Private)

- (void)initCellIfNeeded;

@end

@implementation URLCollectorGroupCell

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[numberOfChildrenCell release];
	
	[super dealloc];
}

- (id)initTextCell:(NSString *)aString
{
	if((self = [super initTextCell:aString])) {
		[self initCellIfNeeded];
	}
	return self;
}

- (id)initImageCell:(NSImage *)image
{
	if((self = [super initImageCell:image])) {
		[self initCellIfNeeded];
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding/NSCopying

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder])) {
		[self initCellIfNeeded];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	if((self = [super copyWithZone:zone])) {
		self->numberOfChildrenCell = [numberOfChildrenCell copyWithZone:zone];
		self->lockImageCell = [lockImageCell copyWithZone:zone];
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

#define kLockImageWidth			16.0
#define kLockImageHeight		16.0
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width - 5.0, cellFrame.size.height);
	
	NSRect groupNameFrame, numberOfChildrenFrame;
	NSString *numberOfChildren = [(URLCollectorGroup *)[self representedObject] formattedNumberOfChildren];
	[numberOfChildrenCell setTitle:numberOfChildren];
	
	NSDictionary *textAttributes	= [[NSDictionary alloc] initWithObjectsAndKeys:[numberOfChildrenCell font], NSFontAttributeName, nil];
	NSSize titleSize				= [numberOfChildren sizeWithAttributes:textAttributes];
	[textAttributes release];

	NSDivideRect(cellFrame, &numberOfChildrenFrame, &groupNameFrame, (titleSize.width + 15.0), NSMaxXEdge);
	[numberOfChildrenCell drawBezelWithFrame:numberOfChildrenFrame inView:controlView];
	[numberOfChildrenCell drawInteriorWithFrame:numberOfChildrenFrame inView:controlView];
	
	if([[self representedObject] isLocked]) {
		NSRect lockRect = NSMakeRect(NSMinX(numberOfChildrenFrame) - 2 - kLockImageWidth, cellFrame.origin.y + 1, kLockImageWidth, kLockImageHeight);
		[lockImageCell setImage:[NSImage imageNamed:NSImageNameLockLockedTemplate]];
		[lockImageCell drawInteriorWithFrame:lockRect inView:controlView];
	}
	[super drawInteriorWithFrame:groupNameFrame inView:controlView];
}

#pragma mark -
#pragma mark Private Methods

- (void)initCellIfNeeded
{
	if(!numberOfChildrenCell) {
		numberOfChildrenCell = [[NSButtonCell alloc] init];
		[numberOfChildrenCell setControlView:[self controlView]];
		[numberOfChildrenCell setBezelStyle:NSRecessedBezelStyle];
	}
	if(!lockImageCell) {
		lockImageCell = [[NSImageCell alloc] initImageCell:nil];
		[lockImageCell setControlView:[self controlView]];
	}
}

@end
