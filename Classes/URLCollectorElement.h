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
@class URLCollectorSource;

@interface URLCollectorElement : URLCollectorNode 
{
	id					data;
	NSString			*elementURL;
	NSMutableArray		*tags;

	URLCollectorGroup	*parentGroup;
	URLCollectorSource	*source;
	
	BOOL				isUnread;
}

@property (nonatomic, retain) id data;
@property (nonatomic, copy) NSString *elementURL;
@property (nonatomic, retain) NSMutableArray *tags;

@property (nonatomic, assign) URLCollectorGroup *parentGroup;
@property (nonatomic, retain) URLCollectorSource *source;

@property (nonatomic, assign) BOOL isUnread;

@end
