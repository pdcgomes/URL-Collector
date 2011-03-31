//
//  ChromeContextContentProvider.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/31/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "URLCollectorContextContentProvider.h"

@class ChromeApplication;

@interface ChromeContextContentProvider : URLCollectorContextContentProvider
{
	ChromeApplication	*application;
}

@end
