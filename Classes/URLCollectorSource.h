//
//  URLCollectorElementSource.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface URLCollectorSource : NSObject 
{
	NSString	*sourceName;
	NSString	*sourceURL;
}

@property (nonatomic, copy) NSString *sourceName;
@property (nonatomic, copy) NSString *sourceURL;


@end
