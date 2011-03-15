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
	NSString			*elementURL;
	NSMutableArray		*tags;

	URLCollectorGroup	*parentGroup;
	URLCollectorContext	*source;
	
	BOOL				isUnread;
}

@property (nonatomic, retain) id data;
@property (nonatomic, copy) NSString *elementURL;
@property (nonatomic, retain) NSMutableArray *tags;

@property (nonatomic, assign) URLCollectorGroup *parentGroup;
@property (nonatomic, retain) URLCollectorContext *source;

@property (nonatomic, assign) BOOL isUnread;

@end
