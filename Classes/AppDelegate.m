//
//  SAPOPunyAppDelegate.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/3/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusItemDraggingDestinationView.h"

@implementation AppDelegate

@synthesize window;
@synthesize collectorPanel;
@synthesize statusMenu;
@synthesize statusItem;

+ (void)initialize
{
	NSArray *shorteningServices = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:@"ShorteningServices"];
	NSAssert([shorteningServices count] > 0, @"No shortening services defined.");
	
	NSArray *defaultService = [shorteningServices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ServiceIsDefault = YES"]];
	if([defaultService count] > 0) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[defaultService objectAtIndex:0] forKey:@"shorteningService"]];
	}
	else {
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[shorteningServices objectAtIndex:0] forKey:@"shorteningService"]];
	}
	
	NSString *databaseFilePath = [[[NSBundle mainBundle] applicationSupportPath] stringByAppendingPathComponent:URLCollectorDatabaseFileName];
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:databaseFilePath forKey:UserDefaults_URLCollectorDatabasePath]];
}

- (void)dealloc
{
	[statusItem release];
	[super dealloc];
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setImage:NSIMAGE(@"menubar-icon")];
	[statusItem setHighlightMode:YES];
	[statusItem setMenu:statusMenu];
	
	StatusItemDraggingDestinationView *statusBarIconView = [[StatusItemDraggingDestinationView alloc] initWithStatusItem:statusItem];
	[statusItem setView:statusBarIconView];

	[statusBarIconView release];

	[collectorPanel setFrameAutosaveName:@"CollectorWindowFrame"];
	[collectorPanel setFrameUsingName:@"CollectorWindowFrame"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	[collectorPanel saveFrameUsingName:@"CollectorWindowFrame"];
	return NSTerminateNow;
}

@end
