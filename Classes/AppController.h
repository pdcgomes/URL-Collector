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

@interface AppController : NSObject <NSOutlineViewDataSource>
{
	IBOutlet NSMenuItem				*collectorMenuItem;
	IBOutlet NSMenuItem				*shortenMenuItem;
	
	IBOutlet SRRecorderControl		*pasteShortcutRecorder;
	IBOutlet SRRecorderControl		*collectorShortcutRecorder;

	IBOutlet URLCollectorDataSource	*urlCollectorDataSource;

	URLShortener				*urlShortener;
	NSMutableArray				*urlCollectorElements;
	NSMutableArray				*selectedElements;
}

@property (nonatomic, readonly) NSArray *shorteningServices;
@property (nonatomic, readonly) NSMutableArray *urlCollectorElements;
@property (nonatomic, readonly) NSMutableArray *selectedElements;

- (IBAction)collector:(id)sender;
- (IBAction)shortenURL:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)configure:(id)sender; 
- (IBAction)quit:(id)sender;

- (IBAction)addGroup:(id)sender;

@end
