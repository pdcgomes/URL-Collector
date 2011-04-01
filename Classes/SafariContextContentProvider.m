//
//  SafariContextContentProvider.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "SafariContextContentProvider.h"
#import "Safari.h"

@implementation SafariContextContentProvider

+ (NSString *)applicationIdentifier
{
	return @"com.apple.Safari";
}

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[application release];
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		application = [[SBApplication applicationWithBundleIdentifier:[[self class] applicationIdentifier]] retain];
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (NSDictionary *)extractContent
{
	if(![application isRunning]) {
		ERROR(@"The application isn't running.");
		return nil;
	}
	
	if([[application windows] count] == 0) {
		return nil;
	}
	
	SafariWindow *firstWindow = [[application windows] objectAtIndex:0];
	SafariTab *activeTab = [firstWindow currentTab];
	
	//	NSString *tabTitle = activeTab.title;
	NSString *tabURLString = activeTab.URL;
	NSURL *tabURL = [NSURL URLWithString:tabURLString];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[tabURL host],				@"identityName",
			tabURL,						@"identityEmailAddress",
			[NSDate date],				@"contextDate",
			@"From",					@"interactionType",
			@"",						@"interactionPreposition",
			nil];
}

@end
