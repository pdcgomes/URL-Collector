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

@interface AppController : NSObject 
{
	IBOutlet NSMenuItem			*collectorMenuItem;
	IBOutlet NSMenuItem			*shortenMenuItem;
	
	IBOutlet SRRecorderControl	*pasteShortcutRecorder;
	IBOutlet SRRecorderControl	*collectorShortcutRecorder;
	
	URLShortener				*urlShortener;
}

@property (nonatomic, readonly) NSArray *shorteningServices;

- (IBAction)collector:(id)sender;
- (IBAction)shortenURL:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)configure:(id)sender; 
- (IBAction)quit:(id)sender;

@end
