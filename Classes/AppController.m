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
#import "URLCollectorSource.h"
#import "URLCollectorDataSource.h"

@interface AppController()

- (void)registerObservers;
- (void)deregisterObservers;

- (void)presentWindow:(NSWindow *)window;
- (void)updateStatusBarMenuItems;

- (BOOL)pasteboardContains:(Class)class;
- (BOOL)hasSelectedRowsOfClass:(Class)objectClass;

@end

@implementation AppController

@synthesize shorteningServices;

- (void)dealloc
{
	[self deregisterObservers];
	
	[urlShortener release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	TRACE(@"");
	
	urlShortener = [[URLShortener alloc] initWithServiceKey:@"SAPOPuny"];
	urlShortener.delegate = self;
	
	[pasteShortcutRecorder setDelegate:self];
	
	[self registerObservers];
	[self updateStatusBarMenuItems];
}

#pragma mark -
#pragma mark SBShortcutRecorderDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	TRACE(@"");
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
	TRACE(@"");
	if([self pasteboardContains:[NSURL class]]) {
		[self shortenURL:self];
	}
}

- (void)collectorHotKeyPressed:(PTHotKey *)hotKey
{
	TRACE(@"");
	NSPanel *collectorPanel = [(AppDelegate *)[NSApplication sharedApplication].delegate collectorPanel];
	if([collectorPanel isVisible]) {
		[collectorPanel orderOut:self];
	}
	else {
		[collectorPanel makeKeyAndOrderFront:nil];
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
	else if([menuItem action] == @selector(shortenURL:)) {
		return [self pasteboardContains:[NSURL class]];
	}
	else if([menuItem action] == @selector(removeRow:)) {
		return [self hasSelectedRowsOfClass:[URLCollectorGroup class]] || [self hasSelectedRowsOfClass:[URLCollectorElement class]];
	}
	else if([menuItem action] == @selector(moveToGroup:)) {
		return [self hasSelectedRowsOfClass:[URLCollectorElement class]] && ![self hasSelectedRowsOfClass:[URLCollectorGroup class]];
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
	[urlCollectorOutlineView expandItem:[urlCollectorOutlineView itemAtRow:groupIndex]];
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
}

- (void)presentWindow:(NSWindow *)window
{
	AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
	
	NSArray *windows = [[NSArray alloc] initWithObjects:[appDelegate window], [appDelegate collectorPanel], nil];
	[windows makeObjectsPerformSelector:@selector(orderOut:) withObject:self];
	[window makeKeyAndOrderFront:self];
}

- (void)updateStatusBarMenuItems
{
	if([collectorShortcutRecorder keyChars]) {
		[collectorMenuItem setKeyEquivalent:[collectorShortcutRecorder keyChars]];
		[collectorMenuItem setKeyEquivalentModifierMask:[collectorShortcutRecorder keyCombo].flags];
	}
	
	if([pasteShortcutRecorder keyChars]) {
		[shortenMenuItem setKeyEquivalent:[pasteShortcutRecorder keyCharsIgnoringModifiers]];
		[shortenMenuItem setKeyEquivalentModifierMask:[pasteShortcutRecorder keyCombo].flags];
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
#pragma mark Helper Methods

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
	for(URLCollectorGroup *group in urlCollectorDataSource.urlCollectorElements) {
		NSMenuItem *groupMenuItem = [[NSMenuItem alloc] initWithTitle:group.name action:@selector(moveToGroup:) keyEquivalent:@""];
		[groupMenuItem setTarget:self];
		[groupMenuItem setRepresentedObject:group];
		[groupsSubmenu addItem:groupMenuItem];
		[groupMenuItem release];
	}
}

@end
