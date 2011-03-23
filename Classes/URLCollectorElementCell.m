//
//  URLCollectorElementCell.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/21/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <BWToolkitFramework/BWToolkitFramework.h>
#import "URLCollectorElementCell.h"

#import "URLCollectorGroup.h"
#import "URLCollectorElement.h"

@interface URLCollectorElementCell(Private)

- (void)initCellIfNeeded;

@end

@implementation URLCollectorElementCell

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[titleCell release];
	[urlCell release];
	[interactionTypeCell release];
	[extraInfoCell release];
	[identityButtonCell release];
	
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
		self->titleCell = [titleCell copyWithZone:zone];
		self->urlCell = [urlCell copyWithZone:zone];
		self->interactionTypeCell = [interactionTypeCell copyWithZone:zone];
		self->identityButtonCell = [identityButtonCell copyWithZone:zone];
		self->extraInfoCell = [extraInfoCell copyWithZone:zone];
//		self->identityButtonCellFrame = identityButtonCellFrame;
	}
	return self;
}

#pragma mark -
#pragma mark NSCell drawing

#define TITLE_LABEL_HEIGHT		18.0
#define URL_BUTTON_HEIGHT		18.0
#define CONTEXT_LABEL_HEIGHT	18.0

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self initCellIfNeeded];
	
	URLCollectorElement *representedObject = [self representedObject];
	if(![representedObject.URLName isEqualToString:representedObject.URL] || !IsEmptyString(representedObject.URLName)) {
		[titleCell setTitle:representedObject.URLName];
	}
	else {
		[titleCell setTitle:@"Link"];
	}
	
	[urlCell setTitle:SKSafeString(representedObject.URL)];
	[interactionTypeCell setTitle:SKSafeString(representedObject.context.interaction)];
	[identityButtonCell setTitle:SKSafeString(representedObject.context.contextName)];
	[extraInfoCell setTitle:SKStringWithFormat(@"(via %@)", representedObject.context.applicationName)];
	
	// Drawing
	NSRect titleCellFrame	= NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, TITLE_LABEL_HEIGHT);
	NSRect urlCellFrame		= NSOffsetRect(titleCellFrame, 0, TITLE_LABEL_HEIGHT + 2.0);
	
	// Interaction type
	NSDictionary *textAttributes	= [[NSDictionary alloc] initWithObjectsAndKeys:[interactionTypeCell font], NSFontAttributeName, nil];
	NSSize interactionTextSize		= [SKSafeString(representedObject.context.interaction) sizeWithAttributes:textAttributes];
	[textAttributes release];
	
	NSUInteger textWidth = ceil(interactionTextSize.width);
	textWidth = textWidth > 0 ? textWidth + 5.0 : 0;
	NSRect interactionCellFrame	= NSMakeRect(cellFrame.origin.x, NSMaxY(urlCellFrame) + 2.0, 
											 textWidth, TITLE_LABEL_HEIGHT);
	
	// Identity string
	textAttributes	= [[NSDictionary alloc] initWithObjectsAndKeys:[identityButtonCell font], NSFontAttributeName, nil];
	NSSize identityTextSize = [SKSafeString(representedObject.context.contextName) sizeWithAttributes:textAttributes];
	[textAttributes release];
	
	textWidth = ceil(identityTextSize.width);
	textWidth = textWidth > 0 ? textWidth + 15.0 : 0;
	identityButtonCellFrame = NSMakeRect(NSMaxX(interactionCellFrame) + 2.0, NSMaxY(urlCellFrame) + 1.0, 
										 textWidth, TITLE_LABEL_HEIGHT);

	// Extra info (application name, etc...)
	textAttributes	= [[NSDictionary alloc] initWithObjectsAndKeys:[extraInfoCell font], NSFontAttributeName, nil];
	NSSize extraInfoTextSize = [[extraInfoCell title] sizeWithAttributes:textAttributes];
	[textAttributes release];
	
	textWidth = ceil(extraInfoTextSize.width);
	textWidth = textWidth > 0 ? textWidth + 5.0 : 0;
	NSRect extraInfoFrame = NSMakeRect(NSMaxX(identityButtonCellFrame) + 2.0, NSMaxY(urlCellFrame) + 2.0, 
									   cellFrame.size.width - NSMaxX(identityButtonCellFrame) + 2.0, TITLE_LABEL_HEIGHT);
	
	[titleCell drawInteriorWithFrame:titleCellFrame inView:controlView];
	[urlCell drawInteriorWithFrame:urlCellFrame inView:controlView];
	[interactionTypeCell drawInteriorWithFrame:interactionCellFrame inView:controlView];
	[identityButtonCell drawBezelWithFrame:identityButtonCellFrame inView:controlView];
	[identityButtonCell drawInteriorWithFrame:identityButtonCellFrame inView:controlView];
	[extraInfoCell drawInteriorWithFrame:extraInfoFrame inView:controlView];
	
//	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	return RGBACOLOR(20, 20, 20, 0.8);
}

#pragma mark -
#pragma mark NSCell mouse tracking

+ (BOOL)prefersTrackingUntilMouseUp
{
	return YES;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	TRACE(@"");

	BOOL highlightIdentityButton = NSMouseInRect(startPoint, identityButtonCellFrame, [controlView isFlipped]);
	TRACE(@"%d", highlightIdentityButton);
	[identityButtonCell setHighlighted:highlightIdentityButton];
	
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	BOOL highlightIdentityButton = NSMouseInRect(currentPoint, identityButtonCellFrame, [controlView isFlipped]);
	TRACE(@"%d", highlightIdentityButton);
	[identityButtonCell setHighlighted:highlightIdentityButton];
	   
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	BOOL isOverIdentityButton = NSMouseInRect(lastPoint, identityButtonCellFrame, [controlView isFlipped]);
	if(isOverIdentityButton) {
		TRACE(@"TODO: SEND ACTION RELATIVE TO THE IDENTITY BUTTON");
	}
	[identityButtonCell setHighlighted:NO];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	NSUInteger hitType = [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
	
	NSPoint point = [event locationInWindow];
	point = [controlView convertPointToBase:point];
	
	LOGRECT(identityButtonCellFrame);
	LOGPOINT(point);
	if(NSMouseInRect(point, identityButtonCellFrame, [controlView isFlipped])) {
		TRACE(@"");
		hitType |= (NSCellHitContentArea|NSCellHitTrackableArea);
	}
	return hitType;
}

#pragma mark -
#pragma mark Private Methods

- (void)initCellIfNeeded
{
	[self setWraps:NO];
//	[self setDrawsBackground:NO];
	
	if(!titleCell) {
		titleCell = [[NSTextFieldCell alloc] initTextCell:@""];
		[titleCell setControlView:[self controlView]];
		[titleCell setDrawsBackground:NO];
		[titleCell setTextColor:[NSColor whiteColor]];
		[titleCell setFont:[NSFont boldSystemFontOfSize:12]];
		[titleCell setLineBreakMode:NSLineBreakByTruncatingMiddle];
	}
	if(!urlCell) {
		urlCell = [[NSTextFieldCell alloc] initTextCell:@""];
		[urlCell setControlView:[self controlView]];
		[urlCell setDrawsBackground:NO];
		[urlCell setTextColor:[NSColor whiteColor]];
		[urlCell setLineBreakMode:NSLineBreakByTruncatingTail];
	} 
	if(!interactionTypeCell) {
		interactionTypeCell = [[NSTextFieldCell alloc] initTextCell:@""];
		[interactionTypeCell setControlView:[self controlView]];
		[interactionTypeCell setDrawsBackground:NO];
		[interactionTypeCell setTextColor:[NSColor whiteColor]];
	}
	if(!identityButtonCell) {
		identityButtonCell = [[NSButtonCell alloc] initTextCell:@""];
		[identityButtonCell setControlView:[self controlView]];
		[identityButtonCell setBezelStyle:NSRecessedBezelStyle];
		identityButtonCellFrame = NSZeroRect;
	}
	if(!extraInfoCell) {
		extraInfoCell = [[NSTextFieldCell alloc] initTextCell:@""];
		[extraInfoCell setControlView:[self controlView]];
		[extraInfoCell setDrawsBackground:NO];
		[extraInfoCell setTextColor:[NSColor whiteColor]];
	}
}

@end
