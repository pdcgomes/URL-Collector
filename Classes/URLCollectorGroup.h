//
//  URLCollectorGroup.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "URLCollectorNode.h"

@class URLCollectorElement;

@interface URLCollectorGroup : URLCollectorNode 
{
	NSColor				*groupColor;
	
	URLCollectorGroup	*parentGroup;
	NSMutableArray		*children;
}

@property (nonatomic, retain) NSColor *groupColor;

@property (nonatomic, assign) URLCollectorGroup *parentGroup;
@property (nonatomic, retain) NSMutableArray *children;

@property (nonatomic, readonly) NSUInteger numberOfElements;

- (void)add:(URLCollectorElement *)element;
- (void)remove:(URLCollectorElement *)element;

@end
