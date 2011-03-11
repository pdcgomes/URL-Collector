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

@interface AppController : NSObject <NSOutlineViewDataSource>
{
	IBOutlet NSMenuItem					*collectorMenuItem;
	IBOutlet NSMenuItem					*shortenMenuItem;
	
	IBOutlet SRRecorderControl			*pasteShortcutRecorder;
	IBOutlet SRRecorderControl			*collectorShortcutRecorder;

	IBOutlet URLCollectorOutlineView	*urlCollectorOutlineView;
	IBOutlet URLCollectorDataSource		*urlCollectorDataSource;

	URLShortener						*urlShortener;
}

@property (nonatomic, readonly) NSArray *shorteningServices;

- (IBAction)collector:(id)sender;
- (IBAction)shortenURL:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)configure:(id)sender; 
- (IBAction)quit:(id)sender;

- (IBAction)addGroup:(id)sender;
- (IBAction)removeRow:(id)sender;

@end
