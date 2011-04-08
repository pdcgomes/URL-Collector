//
//  AppController.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/3/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/SRRecorderControl.h>

@class PTHotKey;
@class URLShortener;
@class URLCollectorDataSource;
@class URLCollectorOutlineView;

@interface AppController : NSObject <NSOutlineViewDelegate, NSWindowDelegate>
{
	IBOutlet NSMenuItem					*collectorMenuItem;
	IBOutlet NSMenuItem					*collectMenuItem;
	IBOutlet NSMenuItem					*shortenMenuItem;
	IBOutlet NSMenu						*groupsSubmenu;
	
	IBOutlet SRRecorderControl			*pasteShortcutRecorder;
	IBOutlet SRRecorderControl			*collectorShortcutRecorder;
	IBOutlet SRRecorderControl			*collectShortcutRecorder;

	IBOutlet URLCollectorOutlineView	*urlCollectorOutlineView;
	IBOutlet URLCollectorDataSource		*urlCollectorDataSource;
	
	URLShortener						*urlShortener;
	
	NSMutableDictionary					*cachedOutlineViewRowHeights;
}

@property (nonatomic, readonly) NSArray *shorteningServices;

- (IBAction)collector:(id)sender;
- (IBAction)shortenURL:(id)sender;
- (IBAction)collectURL:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)configure:(id)sender; 
- (IBAction)quit:(id)sender;

- (IBAction)open:(id)sender;
- (IBAction)addGroup:(id)sender;
- (IBAction)removeRow:(id)sender;
- (IBAction)moveToGroup:(id)sender;

- (IBAction)showIdentity:(id)sender;

- (void)sendToURLCollector:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error;

@end
