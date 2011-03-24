//
//  MailContextContentProvider.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "MailContextContentProvider.h"
#import "Mail.h"

@implementation MailContextContentProvider

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
		application = [[SBApplication applicationWithBundleIdentifier:@"com.apple.mail"] retain];
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
	
	NSArray *messages = [application selection];
	if([messages count] == 0) {
		return nil;
	}
	
	MailMessage *message = [messages objectAtIndex:0];

	NSString *senderName = [application extractNameFrom:[message sender]];
	NSString *senderEmailAddress = [application extractAddressFrom:[message sender]];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			senderName,			@"identityName",
			senderEmailAddress,	@"identityEmailAddress",
			[message subject],	@"messageSubject",
			[message dateSent], @"contextDate",
			@"Mail",			@"interactionType",
			@"from",			@"interactionPreposition",
			nil];
}

@end
