//
//  XcodeContextContentProvider.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "XcodeContextContentProvider.h"
#import "Xcode.h"

@implementation XcodeContextContentProvider

+ (NSString *)applicationIdentifier
{
	return @"com.apple.Xcode";
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
	
	// http://google.com

	if([[application textDocuments] count] == 0) {
		return nil;
	}
	XcodeDocument *doc = [[application textDocuments] objectAtIndex:0];
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[doc name],		@"identityName",
			[doc path],		@"identityEmailAddress",
			[NSDate date],	@"contextDate",
			@"Copy",		@"interactionType",
			@"from",		@"interactionPreposition",
			nil];
}
@end
