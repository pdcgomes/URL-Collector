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

@interface URLCollectorElement : URLCollectorNode 
{
	id					data;
	NSString			*URL;
	NSString			*URLName;
	NSMutableArray		*tags;

	URLCollectorContext	*context;
	NSMutableDictionary	*classification;
	
	BOOL				isUnread;
}

@property (nonatomic, retain) id data;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *URLName;
@property (nonatomic, retain) NSMutableArray *tags;

@property (nonatomic, retain) URLCollectorContext *context;

@property (nonatomic, assign) BOOL isUnread;
@property (nonatomic, readonly) NSDictionary *classification;

- (void)updateClassification:(NSDictionary *)classificationInfo;

@end
