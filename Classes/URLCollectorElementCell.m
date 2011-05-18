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
#import "URLCollectorContentClassifier.h"

@interface URLCollectorElementCell(Private)

- (void)initCellIfNeeded;
- (void)reconfigureSubCellsWithCellFrame:(NSRect)cellFrame;

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
	[iconCell release];
	
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
	URLCollectorElementCell *copy = [super copyWithZone:zone];
	copy->titleCell = [titleCell copyWithZone:zone];
	copy->urlCell = [urlCell copyWithZone:zone];
	copy->interactionTypeCell = [interactionTypeCell copyWithZone:zone];
	copy->identityButtonCell = [identityButtonCell copyWithZone:zone];
	copy->extraInfoCell = [extraInfoCell copyWithZone:zone];
	copy->iconCell = [iconCell copyWithZone:zone];
	
	return copy;
	
//	if((self = [super copyWithZone:zone])) {
//		self->titleCell = [titleCell copyWithZone:zone];
//		self->urlCell = [urlCell copyWithZone:zone];
//		self->interactionTypeCell = [interactionTypeCell copyWithZone:zone];
//		self->identityButtonCell = [identityButtonCell copyWithZone:zone];
//		self->extraInfoCell = [extraInfoCell copyWithZone:zone];
////		self->identityButtonCellFrame = identityButtonCellFrame;
//	}
//	return self;
}

#pragma mark -
#pragma mark NSCell drawing

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self initCellIfNeeded];
	[self reconfigureSubCellsWithCellFrame:cellFrame];
	
	[titleCell drawInteriorWithFrame:titleCellFrame inView:controlView];
	[iconCell drawInteriorWithFrame:iconCellFrame inView:controlView];
	[urlCell drawInteriorWithFrame:urlCellFrame inView:controlView];
	[interactionTypeCell drawInteriorWithFrame:interactionCellFrame inView:controlView];
	[identityButtonCell drawBezelWithFrame:identityButtonCellFrame inView:controlView];
	[identityButtonCell drawInteriorWithFrame:identityButtonCellFrame inView:controlView];
	[extraInfoCell drawInteriorWithFrame:extraInfoCellFrame inView:controlView];
}

#define EXPANSION_FRAME_INSET_AMOUNT 2.0
//- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
//{
//	NSRect innerRect = NSInsetRect(cellFrame, EXPANSION_FRAME_INSET_AMOUNT, EXPANSION_FRAME_INSET_AMOUNT);
//	[[urlCell title] drawAtPoint:innerRect.origin withAttributes:nil];
//}
//

//- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view
//{
//	CGEventRef event = CGEventCreate(NULL);
//	CGPoint location = CGEventGetLocation(event); // global display coordinates (0,0) = top,left
//	CFRelease(event);
//	
//	NSWindow *window = [view window];
////	CGFloat displayHeight = NSHeight([[window screen] frame]);
////	location.y = displayHeight - location.y; // we need convert the coordinate system, since convertScreenToBase assumes Screen coordinate system (0,0) = bottom,left
//
//	CGPoint point = [window convertScreenToBase:location];
//	if([view isFlipped]) {
//		point.y = NSHeight([view frame]) - point.y;
//	}
//	
//	NSSize URLStringSize = [[urlCell title] sizeWithAttributes:nil];
//	if(URLStringSize.width > cellFrame.size.width) {
//		return NSInsetRect(NSMakeRect(point.x, point.y, URLStringSize.width, URLStringSize.height), -EXPANSION_FRAME_INSET_AMOUNT, -EXPANSION_FRAME_INSET_AMOUNT); // replace the hard coded size with the appropriate calculations
//	}
//	return NSZeroRect;
//}

//- (NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
//{
//	return RGBACOLOR(20, 20, 20, 0.8);
//}

#pragma mark -
#pragma mark NSCell mouse tracking

+ (BOOL)prefersTrackingUntilMouseUp
{
	return YES;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	BOOL isOverIdentityButton = NSMouseInRect(startPoint, identityButtonCellFrame, [controlView isFlipped]);
	[identityButtonCell setHighlighted:isOverIdentityButton];
	
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
	BOOL isOverIdentityButton = NSMouseInRect(currentPoint, identityButtonCellFrame, [controlView isFlipped]);
	[identityButtonCell setHighlighted:isOverIdentityButton];
	
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	BOOL isOverIdentityButton = NSMouseInRect(lastPoint, identityButtonCellFrame, [controlView isFlipped]);
	if(isOverIdentityButton) {
		[NSApp sendAction:[self action] to:[self target] from:self];
	}
	[identityButtonCell setHighlighted:NO];
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	NSUInteger hitType = [super hitTestForEvent:event inRect:cellFrame ofView:controlView];

	// Recalculate identityButtonCellFrame here... This is not efficient, but I wasn't able to figure out another way to correctly 
	// determine the identityButtonCellFrame
	// Cells get copied and hittest gets called before the drawing happens
	// Without this, we're likely to get the identityButtonCellFrame for a different cell
	// Need to investigate this further, but this does solve the problem.
	[self reconfigureSubCellsWithCellFrame:cellFrame];
	
	NSPoint point = [event locationInWindow];
	point = [controlView convertPoint:point fromView:nil];
	if(NSMouseInRect(point, identityButtonCellFrame, [controlView isFlipped])) {
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
	if(!iconCell) {
		iconCell = [[NSImageCell alloc] initImageCell:nil];
		[iconCell setControlView:[self controlView]];
	}
}

#define TITLE_LABEL_HEIGHT		18.0
#define URL_BUTTON_HEIGHT		18.0
#define CONTEXT_LABEL_HEIGHT	18.0
#define ICON_SIZE				16.0

- (void)reconfigureSubCellsWithCellFrame:(NSRect)cellFrame
{
	URLCollectorElement *representedObject = [self representedObject];
	if(![representedObject.URLName isEqualToString:representedObject.URL] || !IsEmptyString(representedObject.URLName)) {
		[titleCell setTitle:representedObject.URLName];
	}
	else {
		[titleCell setTitle:@"Link"];
	}
	
	////
	NSString *URLString = [representedObject URL];
	if(![[NSURL URLWithString:URLString] isFileURL]) {
		NSString *host = [[NSURL URLWithString:URLString] host];
		NSRange hostRange = [URLString rangeOfString:host];
		NSRange URLStringRange = NSMakeRange(0, [URLString length]);
		
		NSFont *font = [urlCell font];
		NSColor *hostColor = [NSColor whiteColor];
		NSColor *textColor = RGBCOLOR(190, 190, 190);
		
		NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
		[paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
		[paragraphStyle setLineBreakMode:[urlCell lineBreakMode]];
		
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:URLString];
		[attributedString addAttribute:NSFontAttributeName value:font range:URLStringRange];
		[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:URLStringRange];
		[attributedString addAttribute:NSForegroundColorAttributeName value:textColor range:URLStringRange];
		[attributedString addAttribute:NSForegroundColorAttributeName value:hostColor range:hostRange];
		
		[urlCell setAttributedStringValue:attributedString];
		[attributedString release];
		[paragraphStyle release];
	}
	else {
		// image cleanup
		[urlCell setTitle:SKSafeString(representedObject.URL)];
	}
	////
	[interactionTypeCell setTitle:SKSafeString(representedObject.context.interaction)];
	[identityButtonCell setTitle:SKSafeString(representedObject.context.contextName)];
	[extraInfoCell setTitle:SKStringWithFormat(@"(via %@)", representedObject.context.applicationName)];
	
	// Drawing
	titleCellFrame	= NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, TITLE_LABEL_HEIGHT);
	urlCellFrame	= NSOffsetRect(titleCellFrame, 0, TITLE_LABEL_HEIGHT + 2.0);
	
	if(representedObject.isIconLoaded) {
		[iconCell setImage:representedObject.icon];
		iconCellFrame = NSMakeRect(cellFrame.origin.x, NSMaxY(titleCellFrame) + 2.0, ICON_SIZE, ICON_SIZE);
		urlCellFrame	= NSMakeRect(NSMaxX(iconCellFrame), NSMaxY(titleCellFrame) + 2.0, cellFrame.size.width - NSWidth(iconCellFrame), TITLE_LABEL_HEIGHT);
	}
	else {
		[iconCell setImage:nil];
	}
	
	// Interaction type
	NSDictionary *textAttributes	= [[NSDictionary alloc] initWithObjectsAndKeys:[interactionTypeCell font], NSFontAttributeName, nil];
	NSSize interactionTextSize		= [SKSafeString(representedObject.context.interaction) sizeWithAttributes:textAttributes];
	[textAttributes release];
	
	NSUInteger textWidth = ceil(interactionTextSize.width);
	textWidth = textWidth > 0 ? textWidth + 5.0 : 0;
	interactionCellFrame	= NSMakeRect(cellFrame.origin.x, NSMaxY(urlCellFrame) + 2.0, 
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
	extraInfoCellFrame = NSMakeRect(NSMaxX(identityButtonCellFrame) + 2.0, NSMaxY(urlCellFrame) + 2.0, 
									cellFrame.size.width - NSMaxX(identityButtonCellFrame) + 2.0, TITLE_LABEL_HEIGHT);	
}

@end
