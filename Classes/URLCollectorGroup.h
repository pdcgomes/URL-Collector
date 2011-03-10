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
	NSImage				*groupImage;
	
	URLCollectorGroup	*parentGroup;
}

@property (nonatomic, retain) NSColor *groupColor;
@property (nonatomic, retain) NSImage *groupImage;
@property (nonatomic, assign) URLCollectorGroup *parentGroup;

- (void)add:(URLCollectorElement *)element;
- (void)add:(URLCollectorElement *)element atIndex:(NSInteger)index;

- (void)remove:(URLCollectorElement *)element;

@end
