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

#import "UCIdentityDetailViewController.h"

#import "URLCollectorElementCell.h"
#import "URLCollectorGroupCell.h"

@interface AppController() <NSAnimationDelegate>

- (void)registerObservers;
- (void)deregisterObservers;

- (void)presentWindow:(NSWindow *)window;
- (void)updateStatusBarMenuItems;

- (void)collectURLFromPasteboard:(NSPasteboard *)pasteboard;
- (BOOL)pasteboardContains:(Class)class;
- (BOOL)hasSelectedRowsOfClass:(Class)objectClass;

- (void)updateMenuItemKeyEquivalent:(NSMenuItem *)menuItem withRecorderControl:(SRRecorderControl *)recorderControl;

- (void)presentCollectorPane;
- (void)dismissCollectorPane;

- (void)presentIdentityPaneWithElement:(URLCollectorElement *)element;
- (void)dismissIdentityPane;

- (void)moveSelectedItemsToGroup:(URLCollectorGroup *)group;

- (UCIdentityDetailViewController *)identityDetailViewController;

@end

@implementation AppController

@synthesize shorteningServices;

- (void)dealloc
{
	[self deregisterObservers];
	
	[urlShortener release];
	[cachedOutlineViewRowHeights release];
	[identityDetailViewController release];
	[animationCompletionHandlers release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	TRACE(@"");
	
	urlShortener = [[URLShortener alloc] initWithServiceKey:@"SAPOPuny"];
	urlShortener.delegate = self;
	
	cachedOutlineViewRowHeights = [[NSMutableDictionary alloc] initWithCapacity:10];
	animationCompletionHandlers = [[NSMutableDictionary alloc] initWithCapacity:1];
	
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
	TRACEMARK;
	[self collectURLFromPasteboard:pasteboard];
}

#pragma mark -
#pragma mark SBShortcutRecorderDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	TRACEMARK;
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
		[self dismissCollectorPane];
	}
	else {
		shouldDismissCollectorPanel = NO;
		[collectorPanel setAlphaValue:0.0];
		[collectorPanel makeKeyAndOrderFront:nil];
		[self presentCollectorPane];
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
	else if([menuItem action] == @selector(toggleSyncSupport:)) {
		return YES;
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
	TRACEMARK;
	
	URLCollectorGroup *group = [[URLCollectorGroup alloc] init];
	group.name = NSLocalizedString(@"New group", @"");
	[urlCollectorDataSource addGroup:group];
	[group release];

	[urlCollectorOutlineView editColumn:0 row:[urlCollectorOutlineView numberOfRows] - 1 withEvent:nil select:YES];
}

- (IBAction)addGroupAndMoveSelectedItems:(id)sender
{
	TRACEMARK;
	
	URLCollectorGroup *group = [[URLCollectorGroup alloc] init];
	group.name = NSLocalizedString(@"New group", @"");
	[urlCollectorDataSource addGroup:group];
	[self moveSelectedItemsToGroup:group];

	NSInteger groupRowIndex = [urlCollectorOutlineView numberOfRows] - 1;
	[urlCollectorOutlineView editColumn:0 row:[urlCollectorOutlineView numberOfRows] - 1 withEvent:nil select:YES];
	[urlCollectorOutlineView expandItem:[urlCollectorOutlineView itemAtRow:groupRowIndex]];
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

#define kRemoveContextGroupKey				@"GroupToRemove"
#define kRemoveContextGroupIndexKey			@"IndexOfGroupToRemove"
#define kRemoveContextInitialSelectionKey	@"InitialSelection"

- (IBAction)removeRow:(id)sender
{
	NSIndexSet *selectedRowIndexes = [urlCollectorOutlineView selectedRowIndexes];
	TRACE(@"Removing selected row indexes: %@", selectedRowIndexes);
	
	NSInteger index = [selectedRowIndexes lastIndex];
	while(NSNotFound != index) {
		id representedObject = [[urlCollectorOutlineView itemAtRow:index] representedObject];
		if([representedObject isKindOfClass:[URLCollectorGroup class]] && ![representedObject isLocked]) {
			NSInteger numberOfChildren = [[representedObject children] count];
			if(numberOfChildren > 0) {
				
				NSDictionary *contextInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
											 representedObject, kRemoveContextGroupKey, // stores the group the user asked to delete
											 [NSIndexSet indexSetWithIndex:index], kRemoveContextGroupIndexKey, // stores the selection index of said group
											 selectedRowIndexes, kRemoveContextInitialSelectionKey, // stores a snapshot of the currentSelection -- presenting the AlertSheet will cause the selection to be lost
											 nil];
				NSBeginAlertSheet(@"Removal on non-empty group", @"No", @"Yes", nil, 
								  [[NSApp delegate] collectorPanel], 
								  self, @selector(confirmGroupRemovalSheetDidEnd:returnCode:contextInfo:), nil, (void *)contextInfo,//(void *)representedObject, 
								  SKStringWithFormat(@"The group \"%@\" contains %d elements. Are you sure you want to remove it?", [representedObject name], numberOfChildren));
				break;
			}
			else {
				[urlCollectorDataSource removeGroup:representedObject removeChildren:YES];
			}
		}
		else if([representedObject isKindOfClass:[URLCollectorElement class]]) {
			[urlCollectorDataSource removeElement:representedObject];
		}
		index = [selectedRowIndexes indexLessThanIndex:index];
	}
	[urlCollectorOutlineView deselectAll:self];
}

- (void)confirmGroupRemovalSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSDictionary *context = (NSDictionary *)contextInfo;
	NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] initWithIndexSet:[context objectForKey:kRemoveContextInitialSelectionKey]];
	[indexSet removeIndexes:[context objectForKey:kRemoveContextGroupIndexKey]]; // We should remove this group from the original selection
	
	URLCollectorGroup *group = [context objectForKey:kRemoveContextGroupKey];
	if(returnCode == NSAlertAlternateReturn) {
		[urlCollectorDataSource removeGroup:group removeChildren:YES];
	}
	[urlCollectorOutlineView selectRowIndexes:indexSet byExtendingSelection:NO];
	[indexSet release];
	[context release];
	[self performSelector:@selector(removeRow:) withObject:nil afterDelay:0.3];
}

- (IBAction)moveToGroup:(id)sender
{
	URLCollectorGroup *destinationGroup = [sender representedObject];
	[self moveSelectedItemsToGroup:destinationGroup];
}

- (void)showIdentity:(id)sender
{
	// FIXME: This condition is here because of a weird issue that's causing the action on the cell to be called twice when clicked
	if([sender isKindOfClass:[NSCell class]]) {
		[self presentIdentityPaneWithElement:[sender representedObject]];
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
		TRACE(@"***** WROTE SELECTED ITEMS' TEXT REPRESENTATION TO PASTEBOARD *****");
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

	NSPredicate *searchPredicate = [[NSPredicate predicateWithFormat:@"URLName CONTAINS[cd] $searchString OR URL CONTAINS[cd] $searchString OR context.contextName CONTAINS[cd] $searchString OR context.applicationName CONTAINS[cd] $searchString"] 
									predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:searchString forKey:@"searchString"]];
	[urlCollectorDataSource setPredicate:searchPredicate];
	
	// Automatically expand groups with search results
	// TODO: find a more clean & elegant way to to this -- need a cleaner way to find the row for a given Group or element
	NSArray *groupsWithMatches = [urlCollectorDataSource.urlCollectorElements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"children[SIZE] > 0"]];
	for(URLCollectorGroup *group in groupsWithMatches) {
		for(int i = 0; i < [urlCollectorOutlineView numberOfRows]; ++i) {
			if([[urlCollectorOutlineView itemAtRow:i] representedObject] == group) {
				[urlCollectorOutlineView expandItem:[urlCollectorOutlineView itemAtRow:i]];
			}
		}
	}
}

- (IBAction)focusSearchField:(id)sender
{
	[[[NSApp delegate] collectorPanel] makeFirstResponder:searchField];
}

- (IBAction)toggleSyncSupport:(id)sender
{
	BOOL iCloudSyncEnabled = ![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaults_iCloudSyncEnabled];
	[[NSUserDefaults standardUserDefaults] setBool:iCloudSyncEnabled forKey:UserDefaults_iCloudSyncEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if(iCloudSyncEnabled) {
		TRACE(@"USER ENABLED iCloud SYNC. DO NICE STUFF!");
	}
	else {
		TRACE(@"USER DISABLED iCloud SYNC. DO SAD STUFF!");
	}
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

- (void)moveSelectedItemsToGroup:(URLCollectorGroup *)destinationGroup
{
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

- (UCIdentityDetailViewController *)identityDetailViewController
{
	if(nil == identityDetailViewController) {
		identityDetailViewController = [[UCIdentityDetailViewController alloc] initWithNibName:@"IdentityDetailView" bundle:nil];
		[identityDetailViewController setDelegate:self];
		[identityDetailViewController.view setWantsLayer:YES];
		[identityDetailViewController.view setAlphaValue:0.7];
		[[identityDetailViewController.view layer] setBackgroundColor:CGColorGetConstantColor(kCGColorBlack)];
		[[identityDetailViewController.view layer] setCornerRadius:5.0];
	}
	return identityDetailViewController;
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
		[(URLCollectorElementCell *)cell setSearchExpression:[searchField stringValue]];
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

- (void)windowDidResize:(NSNotification *)notification
{
	NSWindow *window = [notification object];
	NSWindow *childWindow = [[window childWindows] lastObject];
	
	NSRect parentWindowRect		= [window frame];
	NSRect childWindowStartRect = [childWindow frame];
	NSRect childWindowRect		= NSMakeRect(NSMaxX(parentWindowRect), NSMinY(parentWindowRect), childWindowStartRect.size.width, NSHeight(parentWindowRect));
	
	[childWindow setFrame:childWindowRect display:YES];
}

#pragma mark -
#pragma mark UCIdentityDetailViewControllerDelegate

- (void)identityDetailControllerShouldClose:(UCIdentityDetailViewController *)controller
{
	[self dismissIdentityPane];
}

#pragma mark -
#pragma mark Animations

#define COLLECTOR_PANEL_FADE_ANIMATION_DURATION 0.2
- (void)presentCollectorPane
{
	NSDictionary *fadeInAnimationSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
											 [[NSApp delegate] collectorPanel], NSViewAnimationTargetKey, 
											 NSViewAnimationFadeOutEffect , NSViewAnimationEffectKey,
											 nil];
	
	NSViewAnimation *animation = [[NSViewAnimation alloc] initWithDuration:COLLECTOR_PANEL_FADE_ANIMATION_DURATION animationCurve:NSAnimationEaseOut];
	[animation setDelegate:self];
	[animation setViewAnimations:[NSArray arrayWithObject:fadeInAnimationSettings]];
	[animation startAnimation];
	
	[fadeInAnimationSettings release];
	[animation release];
}

- (void)dismissCollectorPane
{
	// First check if the IdentityPane is visible
	// If it is, run it's dismissal animation -- it's completion callback handler will call this method again
	if(identityDetailViewController) {
		shouldDismissCollectorPanel = YES;
		[self dismissIdentityPane];
		return;
	}
	
	NSDictionary *fadeOutAnimationSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
											  [[NSApp delegate] collectorPanel], NSViewAnimationTargetKey, 
											  NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
											  nil];
	NSViewAnimation *animation = [[NSViewAnimation alloc] initWithDuration:COLLECTOR_PANEL_FADE_ANIMATION_DURATION animationCurve:NSAnimationEaseIn];
	[animation setViewAnimations:[NSArray arrayWithObject:fadeOutAnimationSettings]];
	[animation startAnimation];
	
	[fadeOutAnimationSettings release];
	[animation release];
	
	[[[NSApp delegate] collectorPanel] orderOut:self]; // test
}

- (void)presentIdentityPaneWithElement:(URLCollectorElement *)element
{
	if(identityDetailViewController) {
		[identityDetailViewController setRepresentedObject:element];
		return;
	}
	
	
	NSPanel *collectorPanel = [[NSApp delegate] collectorPanel];
	NSRect panelFrame = [collectorPanel frame];
	NSRect childWindowRect = NSMakeRect(NSMaxX(panelFrame) - 360, panelFrame.origin.y, 360, panelFrame.size.height);
	
	NSWindow *childWindow = [[NSWindow alloc] initWithContentRect:childWindowRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[childWindow setBackgroundColor:[NSColor clearColor]];
	[childWindow setOpaque:NO];
	[childWindow setContentView:[[self identityDetailViewController] view]];
	[[self identityDetailViewController] setRepresentedObject:element];
	[[[NSApp delegate] collectorPanel] addChildWindow:childWindow ordered:NSWindowBelow];
	
	/// Setup "drawer" like slide out animation
	NSRect slideAnimationStartFrame = childWindowRect;
	NSRect slideAnimationEndFrame = NSMakeRect(slideAnimationStartFrame.origin.x + NSWidth(slideAnimationStartFrame), slideAnimationStartFrame.origin.y, 
											   slideAnimationStartFrame.size.width, slideAnimationStartFrame.size.height);
	NSDictionary *slideOutAnimation = [[NSDictionary alloc] initWithObjectsAndKeys:
									   childWindow, NSViewAnimationTargetKey,
									   [NSValue valueWithRect:slideAnimationStartFrame], NSViewAnimationStartFrameKey,
									   [NSValue valueWithRect:slideAnimationEndFrame], NSViewAnimationEndFrameKey,
									   nil];
	NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithDuration:0.2 animationCurve:NSAnimationEaseIn];
	[viewAnimation setViewAnimations:[NSArray arrayWithObject:slideOutAnimation]];
	[slideOutAnimation release];
	
	[viewAnimation startAnimation];
	[viewAnimation release];
	
	// Observe collectorPanel frame changes so that we can keep the identityPane positioned correctly in relation to it
	[collectorPanel setDelegate:self];
}

- (void)dismissIdentityPane
{
	NSPanel *collectorPanel = [[NSApp delegate] collectorPanel];
	NSWindow *childWindow = [[collectorPanel childWindows] lastObject];
	NSRect childWindowRect = [childWindow frame];
	
	NSRect slideAnimationStartFrame = childWindowRect;
	NSRect slideAnimationEndFrame = NSMakeRect(slideAnimationStartFrame.origin.x - NSWidth(slideAnimationStartFrame), slideAnimationStartFrame.origin.y, 
											   slideAnimationStartFrame.size.width, slideAnimationStartFrame.size.height);
	NSDictionary *slideOutAnimation = [[NSDictionary alloc] initWithObjectsAndKeys:
									   childWindow, NSViewAnimationTargetKey,
									   [NSValue valueWithRect:slideAnimationStartFrame], NSViewAnimationStartFrameKey,
									   [NSValue valueWithRect:slideAnimationEndFrame], NSViewAnimationEndFrameKey,
									   nil];
	NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithDuration:0.2 animationCurve:NSAnimationEaseIn];
	[viewAnimation setViewAnimations:[NSArray arrayWithObject:slideOutAnimation]];
	[viewAnimation setDelegate:self];
	[slideOutAnimation release];

	NSString *animationKey = SKStringWithFormat(@"%d", [viewAnimation hash]);
	TRACE(@"animationKey <%@>", animationKey);
	[animationCompletionHandlers setObject:NSStringFromSelector(@selector(handleDidEndIdentityPaneDismissalAnimation)) forKey:animationKey];
	
	[viewAnimation startAnimation];
	[viewAnimation release];
	
	// Stop observing collectorPanel frame changes
	[collectorPanel setDelegate:nil];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	NSString *animationKey = SKStringWithFormat(@"%d", [animation hash]);
	if(![animationCompletionHandlers objectForKey:animationKey]) {
		return;
	}
	
	NSString *completionHandlerSelectorString = [animationCompletionHandlers objectForKey:animationKey];
	if(completionHandlerSelectorString) {
		SEL completionHandler = NSSelectorFromString(completionHandlerSelectorString);
		NSAssert([self respondsToSelector:completionHandler], @"Undefined completion handler <%@> for animation <%@>", completionHandlerSelectorString, animation);
		
		[self performSelector:completionHandler];
	}
}

#pragma mark -
#pragma mark Animation Completion Handlers

- (void)handleDidEndIdentityPaneDismissalAnimation
{
	[identityDetailViewController release], identityDetailViewController = nil;

	NSPanel *collectorPanel = [[NSApp delegate] collectorPanel];
	NSWindow *childWindow = [[collectorPanel childWindows] lastObject];
	[collectorPanel removeChildWindow:childWindow];
	[childWindow close];
	
	if(shouldDismissCollectorPanel) {
		[self dismissCollectorPane];
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
	[groupsSubmenu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *addGroupMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"New...", @"") action:@selector(addGroupAndMoveSelectedItems:) keyEquivalent:@""];
	[addGroupMenuItem setTarget:self];
	[groupsSubmenu addItem:addGroupMenuItem];
	[addGroupMenuItem release];
}

- (void)pasteboardChangeCountUpdated:(NSString *)keyPath ofObject:(id)target change:(NSDictionary *)change userInfo:(id)userInfo
{
	TRACE(@"");
}

@end
