//
//  ContextRecognizer.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorContext;

@interface URLCollectorContextRecognizer : NSObject 
{
	NSDictionary	*supportedApplications;
}

+ (id)sharedInstance;

// Listens for application switches in the background and attempts to detect and collect supported data
- (void)startAutomaticContextRecognition;
- (void)stopAutomaticContextRecognition;

- (URLCollectorContext *)guessContextFromActiveApplication;
- (URLCollectorContext *)guessContextFromApplication:(NSDictionary *)applicationInfo;

@end
