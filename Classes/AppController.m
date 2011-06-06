//
//  AppController.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/3/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <ShortcutRecorder/ShortcutRecorder.h>
#import "AppController.h"
#import "AppDelegate.h"

#import "PTHotKeyCenter.h"
#import "PTHotKey.h"
#import "URLShortener.h"

#import "URLCollectorGroup.h"
#import "URLCollectorElement.h"
#import "URLCollectorContext.h"
#import "URLCollectorDataSource.h"
#import "URLCollectorOutlineView.h"

#import "URLCollectorElementCell.h"
#import "URLCollectorGroupCell.h"

@interface AppController()

- (void)registerObservers;
- (void)deregisterObservers;

- (void)presentWindow:(NSWindow *)window;
- (void)updateStatusBarMenuItems;

- (void)collectURLFromPasteboard:(NSPasteboard *)pasteboard;
- (BOOL)pasteboardContains:(Class)class;
- (BOOL)hasSelectedRowsOfClass:(Class)objectClass;

- (void)updateMenuItemKeyEquivalent:(NSMenuItem *)menuItem withRecorderControl:(SRRecorderControl *)recorderControl;

@end

@implementation AppController

@synthesize shorteningServices;

- (void)dealloc
{
	[self deregisterObservers];
	
	[urlShortener release];
	[cachedOutlineViewRowHeights release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	TRACE(@"");
	
	urlShortener = [[URLShortener alloc] initWithServiceKey:@"SAPOPuny"];
	urlShortener.delegate = self;
	
	cachedOutlineViewRowHeights = [[NSMutableDictionary alloc] initWithCapacity:10];
	
	[urlCollectorDataSource setOutlineView:urlCollectorOutlineView];
	[pasteShortcutRecorder setDelegate:self];
	
	[self registerObservers];
	[self updateStatusBarMenuItems];

	[NSApp setServicesProvider:self];
	NSUpdateDynamicServices();
}

#pragma mark -
#pragma mark ServicesProvider

- (void)sendToURLCollector:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error
{
	TRACE(@"");
	[self collectURLFromPasteboard:pasteboard];
}

#pragma mark -
#pragma mark SBShortcutRecorderDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	TRACE(@"");
	NSMutableSet *shortcutRecorders = [[NSMutableSet alloc] initWithObjects:pasteShortcutRecorder, collectorShortcutRecorder, collectShortcutRecorder, nil];
	[shortcutRecorders removeObject:aRecorder];
	
	for(SRRecorderControl *recorder in shortcutRecorders) {
		if([recorder keyCombo].code == keyCode && [recorder keyCombo].flags == flags) {
			if(aReason) {
				*aReason = NSLocalizedString(@"The selected shortcut is already in use.", @"");
			}
			return YES;
		}
	}
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	TRACE(@"");
	
	NSString *hotKeyID = nil;
	SEL hotKeyAction = nil;
	
	if(aRecorder == pasteShortcutRecorder) {
		hotKeyID = @"PasteHotKey";
		hotKeyAction = @selector(pasteHotKeyPressed:);
	}
	else if(aRecorder == collectShortcutRecorder) {
		hotKeyID = @"CollectURLHotKey";
		hotKeyAction = @selector(collectURLHotKeyPressed:);
	}
	else {
		hotKeyID = @"CollectorHotKey";
		hotKeyAction = @selector(collectorHotKeyPressed:);
	}

	PTHotKey *hotKey = [[PTHotKeyCenter sharedCenter] hotKeyWithIdentifier:hotKeyID];
	if(hotKey) {
		[[PTHotKeyCenter sharedCenter] unregisterHotKey:hotKey];
	}
	hotKey = [[PTHotKey alloc] initWithIdentifier:hotKeyID
											  keyCombo:[PTKeyCombo keyComboWithKeyCode:[aRecorder keyCombo].code
																			 modifiers:[aRecorder cocoaToCarbonFlags:[aRecorder keyCombo].flags]]];
	[hotKey setTarget:self];
	[hotKey setAction:hotKeyAction];
	[[PTHotKeyCenter sharedCenter] registerHotKey:hotKey];
	[hotKey release];
	
	[self updateStatusBarMenuItems];
}

#pragma mark -
#pragma mark HotKey Handling

- (void)pasteHotKeyPressed:(PTHotKey *)hotKey
{
	if([self pasteboardContains:[NSURL class]]) {
		[self shortenURL:self];
	}
}

- (void)collectorHotKeyPressed:(PTHotKey *)hotKey
{
	NSPanel *collectorPanel = [(AppDelegate *)[NSApplication sharedApplication].delegate collectorPanel];
	if([collectorPanel isVisible]) {
		[collectorPanel orderOut:self];
	}
	else {
		[collectorPanel makeKeyAndOrderFront:nil];
	}
}

- (void)collectURLHotKeyPressed:(PTHotKey *)hotKey
{
	if([self pasteboardContains:[NSURL class]]) {
		[self collectURL:self];
	}
}

#pragma mark -
#pragma mark MenuItem validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if([menuItem action] == @selector(quit:) ||
	   [menuItem action] == @selector(configure:)) {
		return YES;
	}
	else if([menuItem action] == @selector(copy:)) {
		return NO;
	}
	else if([menuItem action] == @selector(collectURL:)) {
		return [self pasteboardContains:[NSURL class]];
	}
	else if([menuItem action] == @selector(shortenURL:)) {
		return [self pasteboardContains:[NSURL class]];
	}
	else if([menuItem action] == @selector(open:)) {
		return [self hasSelectedRowsOfClass:[URLCollectorElement class]] && ![self hasSelectedRowsOfClass:[URLCollectorGroup class]];
	}
	else if([menuItem action] == @selector(removeRow:)) {
		return [self hasSelectedRowsOfClass:[URLCollectorGroup class]] || [self hasSelectedRowsOfClass:[URLCollectorElement class]];
	}
	else if([menuItem action] == @selector(moveToGroup:)) {
		return [self hasSelectedRowsOfClass:[URLCollectorElement class]] && ![self hasSelectedRowsOfClass:[URLCollectorGroup class]];
	}
	else if([menuItem action] == @selector(exportAsText:)) { // Only allow exporting of elements
		return [self hasSelectedRowsOfClass:[URLCollectorElement class]] || ![self hasSelectedRowsOfClass:[URLCollectorGroup class]];
	}
	else {
		return YES;
	}
}

- (BOOL)hasSelectedRowsOfClass:(Class)objectClass
{
	NSIndexSet *selectedRowIndexes = [urlCollectorOutlineView selectedRowIndexes];
	if([selectedRowIndexes count] == 0) {
		return NO;
	}
	
	NSUInteger index = [selectedRowIndexes firstIndex];
	while(NSNotFound != index) {
		id representedObject = [[urlCollectorOutlineView itemAtRow:index] representedObject];
		if([representedObject isKindOfClass:objectClass]) {
			return YES;
		}
		index = [selectedRowIndexes indexGreaterThanIndex:index];
	}
	
	return NO;
}

#pragma mark -
#pragma mark Actions

- (IBAction)collector:(id)sender
{
	[self presentWindow:[(AppDelegate *)[NSApplication sharedApplication].delegate collectorPanel]];
}

- (IBAction)shortenURL:(id)sender
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSArray *items = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:nil];
	TRACE(@"Pasteboard items of type <NSURL>: %@", items);
	if([items count] > 0) {
		NSString *theURL = [[items objectAtIndex:0] absoluteString];
		if([URLShortener isValidURL:theURL]) {
			[urlShortener shortenURL:theURL];
		}
	}
}

- (IBAction)collectURL:(id)sender
{
	[self collectURLFromPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)copy:(id)sender
{
	
}

- (IBAction)configure:(id)sender
{
	[self presentWindow:[(AppDelegate *)[NSApplication sharedApplication].delegate window]];
}

- (IBAction)quit:(id)sender
{
	[NSApp terminate:self];
}

- (IBAction)addGroup:(id)sender
{
	TRACE(@"");
	
	URLCollectorGroup *group = [[URLCollectorGroup alloc] init];
	group.name = NSLocalizedString(@"New group", @"");
	[urlCollectorDataSource addGroup:group];
	[group release];

	[urlCollectorOutlineView editColumn:0 row:[urlCollectorOutlineView numberOfRows] - 1 withEvent:nil select:YES];
}

- (IBAction)open:(id)sender
{
	TRACE(@"");
	
	NSIndexSet *selectedRowIndexes = [urlCollectorOutlineView selectedRowIndexes];
	NSInteger index = [selectedRowIndexes firstIndex];
	while(NSNotFound != index) {
		id representedObject = [[urlCollectorOutlineView itemAtRow:index] representedObject];
		if([representedObject isKindOfClass:[URLCollectorElement class]]) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[(URLCollectorElement *)representedObject URL]]];
		}
		index = [selectedRowIndexes indexGreaterThanIndex:index];
	}
}

- (IBAction)removeRow:(id)sender
{
	NSIndexSet *selectedRowIndexes = [urlCollectorOutlineView selectedRowIndexes];
	TRACE(@"Removing selected row indexes: %@", selectedRowIndexes);
	
	NSInteger index = [selectedRowIndexes lastIndex];
	while(NSNotFound != index) {
		id representedObject = [[urlCollectorOutlineView itemAtRow:index] representedObject];
		if([representedObject isKindOfClass:[URLCollectorGroup class]]) {
			[urlCollectorDataSource removeGroup:representedObject removeChildren:NO];
		}
		else if([representedObject isKindOfClass:[URLCollectorElement class]]) {
			[urlCollectorDataSource removeElement:representedObject];
		}
		index = [selectedRowIndexes indexLessThanIndex:index];
	}
	[urlCollectorOutlineView deselectAll:self];
}

- (IBAction)moveToGroup:(id)sender
{
	URLCollectorGroup *destinationGroup = [sender representedObject];
	NSIndexSet *selectedRowIndexes = [urlCollectorOutlineView selectedRowIndexes];
	NSInteger index = [selectedRowIndexes lastIndex];
	while(NSNotFound != index) {
		id representedObject = [[urlCollectorOutlineView itemAtRow:index] representedObject];
		NSAssert([representedObject isKindOfClass:[URLCollectorElement class]], SKStringWithFormat(@"Attempting to move an unsupported type <%@> to a group. This is unsupported.", representedObject));
		
		[urlCollectorDataSource addElement:representedObject toGroup:destinationGroup];
		index = [selectedRowIndexes indexLessThanIndex:index];
	}
	[urlCollectorOutlineView deselectAll:self];
	
	NSInteger groupIndex = [urlCollectorDataSource.urlCollectorElements indexOfObject:destinationGroup];
	id groupItem = [urlCollectorOutlineView itemAtRow:groupIndex];
	if(![urlCollectorOutlineView isItemExpanded:groupItem]) {
		[urlCollectorOutlineView expandItem:[urlCollectorOutlineView itemAtRow:groupIndex]];
	}
}

- (void)showIdentity:(id)sender
{
	// FIXME: This condition is here because of a weird issue that's causing the action on the cell to be called twice when clicked
	if([sender isKindOfClass:[NSCell class]]) {
		TRACE(@"***** TODO: PRESENT IDENTITY WINDOW");
	}
}

- (IBAction)exportAsText:(id)sender
{
	NSIndexSet *selectedRowIndexes = [urlCollectorOutlineView selectedRowIndexes];
	
	NSInteger index = [selectedRowIndexes firstIndex];
	NSMutableString *textRepresentation = [[NSMutableString alloc] initWithString:@"--------------------\n"];

	TRACE(@"***** BUILDING TEXT REPRESENTATION ... *****");
	while(NSNotFound != index) {
		URLCollectorElement *representedObject = [[urlCollectorOutlineView itemAtRow:index] representedObject];
		[textRepresentation appendString:[representedObject stringRepresentation]];
		index = [selectedRowIndexes indexGreaterThanIndex:index];
	}
	
	TRACE(@"%@", textRepresentation);
	
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	
	if([pasteboard writeObjects:[NSArray arrayWithObject:textRepresentation]]) {
		TRACE(@"***** WROTE SELECTED ITEMS TEXT REPRESENTATION TO PASTEBOARD *****");
	}
	else {
		TRACE(@"***** UNABLE TO EXPORT SELECTED ITEMS TO PASTEBOARD! *****");
	}
	[textRepresentation release];
}

#define MIN_SEARCH_STRING_LENGTH 3
- (IBAction)updateSearchFilter:(id)sender
{
	NSString *searchString = [sender stringValue];
	if([searchString length] < MIN_SEARCH_STRING_LENGTH) {
		[urlCollectorDataSource setPredicate:nil];
		return;
	}

	[urlCollectorDataSource setPredicate:[NSPredicate predicateWithFormat:@"URLName CONTAINS[cd] %@ OR URL CONTAINS[cd] %@ OR context.contextName CONTAINS[cd] %@", searchString, searchString, searchString]];
}

#pragma mark -
#pragma mark Properties

- (NSArray *)shorteningServices
{
	return [URLShortener supportedShorteningServices];
}

#pragma mark -
#pragma mark Private Methods

- (void)registerObservers
{
	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:UserDefaults_ShorteningService selector:@selector(shorteningServiceChanged:ofObject:change:userInfo:) userInfo:nil options:0];
	[urlCollectorDataSource addObserver:self forKeyPath:@"urlCollectorElements" selector:@selector(dataSourceChanged:ofObject:change:userInfo:) userInfo:nil options:0];
}

- (void)deregisterObservers
{
	[[NSUserDefaults standardUserDefaults] removeObserver:self keyPath:UserDefaults_ShorteningService selector:@selector(shorteningServiceChanged:ofObject:change:userInfo:)];
	[urlCollectorDataSource removeObserver:self keyPath:@"urlCollectorElements" selector:@selector(dataSourceChanged:ofObject:change:userInfo:)];
}

- (void)presentWindow:(NSWindow *)window
{
	AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
	
	NSMutableSet *windows = [[NSMutableSet alloc] initWithObjects:[appDelegate window], [appDelegate collectorPanel], nil];
	[windows removeObject:window];
	[windows makeObjectsPerformSelector:@selector(close) withObject:self];
	[windows release];
	
	[window orderFrontRegardless];
	[window makeKeyWindow];
}

#define MENU_ITEM			0
#define	SHORTCUT_RECORDER	1
- (void)updateStatusBarMenuItems
{
	[collectorMenuItem setRepresentedObject:collectorShortcutRecorder];
	[collectMenuItem setRepresentedObject:collectShortcutRecorder];
	[shortenMenuItem setRepresentedObject:pasteShortcutRecorder];
	
	NSArray *menuItems = [[NSArray alloc] initWithObjects:collectorMenuItem, collectMenuItem, shortenMenuItem, nil];
	for(NSMenuItem *menuItem in menuItems) {
		[self updateMenuItemKeyEquivalent:menuItem withRecorderControl:[menuItem representedObject]];
	}
	[menuItems release];
	
//	NSMenuItem *menuItems[3] = { collectorMenuItem, collectMenuItem, shortenMenuItem };
//	for(int i = 0; i < SKArrayLength(menuItems); i++) {
//		[self updateMenuItemKeyEquivalent:menuItems[i] withRecorderControl:[menuItems[i] representedObject]];
//	}
	
	// matrix that maps a given menuItem to the shortCutRecorder that it's representing
//	id shortcuts[][2] = {
//		{collectorMenuItem, collectorShortcutRecorder},
//		{collectMenuItem, collectShortcutRecorder},
//		{shortenMenuItem, pasteShortcutRecorder}
//	};
//	
//	for(int i = 0; i < SKArrayLength(shortcuts); i++) {
//		[self updateMenuItemKeyEquivalent:shortcuts[i][MENU_ITEM] withRecorderControl:shortcuts[i][SHORTCUT_RECORDER]];
//	}
}

#define PTHotKeySpecialKeyCode	0
#define NSEventSpecialKeyCode	1
- (void)updateMenuItemKeyEquivalent:(NSMenuItem *)menuItem withRecorderControl:(SRRecorderControl *)recorderControl
{
	// Currently only supporting Function "special keys"
	// May need to support others in the future
	// Couldn't figure out other way to get the appropriate unichar representation of some special keys (mainly Function keys), decided to map them instead
	// I'm sure there's an easier way
	static int functionKeyMap[][2] = {
		{kSRKeysF1, NSF1FunctionKey},
		{kSRKeysF2, NSF2FunctionKey},
		{kSRKeysF3, NSF3FunctionKey},
		{kSRKeysF4, NSF4FunctionKey},
		{kSRKeysF5, NSF5FunctionKey},
		{kSRKeysF6, NSF6FunctionKey},
		{kSRKeysF7, NSF7FunctionKey},
		{kSRKeysF8, NSF8FunctionKey},
		{kSRKeysF9, NSF9FunctionKey},
		{kSRKeysF10, NSF10FunctionKey},
		{kSRKeysF11, NSF11FunctionKey},
		{kSRKeysF12, NSF12FunctionKey},
		{kSRKeysF13, NSF13FunctionKey},
		{kSRKeysF14, NSF14FunctionKey},
		{kSRKeysF15, NSF15FunctionKey},
		{kSRKeysF16, NSF16FunctionKey},
		{kSRKeysF17, NSF17FunctionKey},
		{kSRKeysF18, NSF18FunctionKey},
		{kSRKeysF19, NSF19FunctionKey},
	};

	if([recorderControl keyChars]) {
		[menuItem setKeyEquivalent:[recorderControl keyCharsIgnoringModifiers]];
		if(SRIsSpecialKey([recorderControl keyCombo].code)) {
			for(int i = 0; i < SKArrayLength(functionKeyMap); i++) {
				if([recorderControl keyCombo].code == functionKeyMap[i][PTHotKeySpecialKeyCode]) {
					[menuItem setKeyEquivalent:SKStringWithFormat(@"%C", functionKeyMap[i][NSEventSpecialKeyCode])];
					break;
				}
			}
		}
		else {
			[menuItem setKeyEquivalent:[recorderControl keyChars]];
		}
		[menuItem setKeyEquivalentModifierMask:[recorderControl keyCombo].flags];
	}
}

#pragma mark -
#pragma mark URLShortenerDelegate

- (void)URLShortener:(URLShortener *)shortener didShortenURL:(NSString *)URL withResult:(NSString *)shortURL
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard clearContents];
	[pasteboard writeObjects:[NSArray arrayWithObject:[NSURL URLWithString:shortURL]]];
}

#pragma mark -
#pragma mark NSOutlineViewDelegate

#define DEFAULT_ROW_HEIGHT_CACHE_SIZE	50
#define DEFAULT_GROUP_ROW_HEIGHT		20.0
#define DEFAULT_ELEMENT_ROW_HEIGHT		65.0
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	NSIndexPath *itemIndexPath = [item indexPath];
	NSNumber *rowHeight = [cachedOutlineViewRowHeights objectForKey:itemIndexPath];
	if(rowHeight) {
		return [rowHeight floatValue];
	}
	
	if([cachedOutlineViewRowHeights count] >= DEFAULT_ROW_HEIGHT_CACHE_SIZE) {
		[cachedOutlineViewRowHeights removeAllObjects];
	}
	if([[item representedObject] isKindOfClass:[URLCollectorElement class]]) {
		rowHeight = [NSNumber numberWithFloat:DEFAULT_ELEMENT_ROW_HEIGHT];
	}
	else {
		rowHeight = [NSNumber numberWithFloat:DEFAULT_GROUP_ROW_HEIGHT];
	}
	[cachedOutlineViewRowHeights setObject:rowHeight forKey:itemIndexPath];
	return [rowHeight floatValue];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	// Currently only supporting inline edit for Groups
	return [[item representedObject] isKindOfClass:[URLCollectorGroup class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return [[item representedObject] isKindOfClass:[URLCollectorGroup class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	return [[item representedObject] isKindOfClass:[URLCollectorElement class]];
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
//	if(tableColumn == nil) {
//		return nil;
//	}
	NSCell *cell = nil;
	if([[item representedObject] isKindOfClass:[URLCollectorGroup class]]) {
		cell = [[[URLCollectorGroupCell alloc] initTextCell:@""] autorelease];
		[cell setEditable:YES];
	}
	else if([[item representedObject] isKindOfClass:[URLCollectorElement class]]) {
		cell = [tableColumn dataCellForRow:[outlineView rowForItem:item]];
		[cell setTarget:self];
		[cell setAction:@selector(showIdentity:)];
	}
	return cell;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if([[item representedObject] isKindOfClass:[URLCollectorGroup class]] ||
	   [[item representedObject] isKindOfClass:[URLCollectorElement class]]) {
		[cell setRepresentedObject:[item representedObject]];
	}
}

- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation
{
	id representedObject = [item representedObject];
	if([representedObject isKindOfClass:[URLCollectorElement class]]) {
		return [(URLCollectorElement *)representedObject URL];
	}
	return [(URLCollectorGroup *)representedObject name];
}

#pragma mark -
#pragma mark NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	TRACE(@"");
	if([notification object] == [(AppDelegate *)[NSApp delegate] window]) {
		
	}
}

- (void)windowWillClose:(NSNotification *)notification
{
	TRACE(@"");
	if([notification object] == [(AppDelegate *)[NSApp delegate] window]) {

	}
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	TRACE(@"");
	
	if([notification object] == [(AppDelegate *)[NSApp delegate] window]) {
		[[(AppDelegate *)[NSApp delegate] window] close];
	}
}

#pragma mark -
#pragma mark Helper Methods

- (void)collectURLFromPasteboard:(NSPasteboard *)pasteboard
{
	NSArray *items = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
	if([items count] > 0) {
		NSString *theURL = [items objectAtIndex:0];
		if([URLShortener isValidURL:theURL]) {
			if(![URLShortener conformsToRFC1808:theURL]) {
				theURL = SKStringWithFormat(@"http://%@", theURL);
			}
			[urlCollectorDataSource addURLToInbox:theURL];
		}
	}
}

- (BOOL)pasteboardContains:(Class)class
{
	return [[[NSPasteboard generalPasteboard] readObjectsForClasses:[NSArray arrayWithObject:class] options:nil] count] > 0;
}

#pragma mark -
#pragma mark KVO

- (void)shorteningServiceChanged:(NSString *)keyPath ofObject:(id)target change:(NSDictionary *)change userInfo:(id)userInfo
{
	TRACE(@"***** SHORTENING SERVICE WAS UPDATED TO <%@>", @"TODO");
	[urlShortener release];
	urlShortener = nil;
	
	urlShortener = [[URLShortener alloc] initWithServiceKey:@"SAPOPuny"];
	urlShortener.delegate = self;
}

- (void)dataSourceChanged:(NSString *)keyPath ofObject:(id)target change:(NSDictionary *)change userInfo:(id)userInfo
{
	// Reload contextual menu items
	
	TRACE(@"Reloading 'Move to group' contextual menu...");
	[groupsSubmenu removeAllItems];
	for(URLCollectorNode *node in urlCollectorDataSource.urlCollectorElements) {
		if(![node isKindOfClass:[URLCollectorGroup class]]) {
			continue;
		}
		NSMenuItem *groupMenuItem = [[NSMenuItem alloc] initWithTitle:node.name action:@selector(moveToGroup:) keyEquivalent:@""];
		[groupMenuItem setTarget:self];
		[groupMenuItem setRepresentedObject:node];
		[groupsSubmenu addItem:groupMenuItem];
		[groupMenuItem release];
	}
}

- (void)pasteboardChangeCountUpdated:(NSString *)keyPath ofObject:(id)target change:(NSDictionary *)change userInfo:(id)userInfo
{
	TRACE(@"");
}

@end
