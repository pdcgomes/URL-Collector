//
//  AdiumContextRecognizer.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "URLCollectorContextContentProvider.h"

@class AdiumApplication;

@interface AdiumContextContentProvider : URLCollectorContextContentProvider 
{
	AdiumApplication	*application;
}

@end
