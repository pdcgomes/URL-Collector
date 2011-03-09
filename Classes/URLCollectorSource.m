//
//  URLCollectorElementSource.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorSource.h"

@implementation URLCollectorSource

@synthesize sourceName;
@synthesize sourceURL;


- (void)dealloc
{
	SKSafeRelease(sourceName);	
	SKSafeRelease(sourceURL);
	
	[super dealloc];
}

@end
