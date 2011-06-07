//
//  SAPOPunyAppDelegate.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/3/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> 
{
    NSWindow		*window;
	NSPanel			*collectorPanel;
	NSMenu			*statusMenu;
	NSStatusItem	*statusItem;
}

@property (assign) IBOutlet NSWindow		*window;
@property (assign) IBOutlet NSPanel			*collectorPanel;
@property (assign) IBOutlet NSMenu			*statusMenu;
@property (assign) IBOutlet NSStatusItem	*statusItem;

@end
