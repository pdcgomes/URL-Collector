//
//  URLCollectorElement.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "URLCollectorNode.h"

@class URLCollectorGroup;
@class URLCollectorContext;

@interface URLCollectorElement : URLCollectorNode 
{
	id					data;
	NSString			*URL;
	NSString			*URLName;
	NSMutableArray		*tags;

	URLCollectorGroup	*parentGroup;
	URLCollectorContext	*context;
	
	BOOL				isUnread;
}

@property (nonatomic, retain) id data;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *URLName;
@property (nonatomic, retain) NSMutableArray *tags;

@property (nonatomic, assign) URLCollectorGroup *parentGroup;
@property (nonatomic, retain) URLCollectorContext *context;

@property (nonatomic, assign) BOOL isUnread;

@end
