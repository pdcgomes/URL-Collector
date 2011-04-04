//
//  URLCollectorElement.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "URLCollectorNode.h"
#import "URLCollectorContext.h"

@class URLCollectorGroup;
@class UCImageLoader;

@interface URLCollectorElement : URLCollectorNode 
{
	id					data;
	NSString			*URL;
	NSString			*URLName;
	NSImage				*icon;
	NSMutableArray		*tags;

	URLCollectorContext	*context;
	NSMutableDictionary	*classification;
	
	BOOL				isUnread;
	
	UCImageLoader		*imageLoader;
	BOOL				isIconLoaded;
}

@property (nonatomic, retain) id data;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *URLName;
@property (nonatomic, retain) NSMutableArray *tags;

@property (nonatomic, retain) URLCollectorContext *context;

@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, assign) BOOL isUnread;
@property (nonatomic, readonly) BOOL isIconLoaded;
@property (nonatomic, readonly) NSDictionary *classification;

- (void)updateClassification:(NSDictionary *)classificationInfo;
- (void)loadIconIfNeeded;

@end
