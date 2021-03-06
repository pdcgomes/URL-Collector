//
//  AdiumContextRecognizer.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "AdiumContextContentProvider.h"
#import "Adium.h"

@implementation AdiumContextContentProvider

+ (NSString *)applicationIdentifier
{
	return @"com.adiumX.adiumX";
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
		application = [[SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"] retain];
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

	AdiumChat *adiumChat = [application activeChat];
	AdiumAccount *adiumAccount = [adiumChat account];
	AdiumService *adiumService = [adiumAccount service];
	
	SBElementArray *chatContacts = [adiumChat contacts];

	AdiumContact *adiumContact = [chatContacts lastObject];
	TRACE(@"Grabbed identity from adiumContact <%@>", adiumContact);
	
	// TODO
	// Build identity dict
	// Build additional content dict
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[adiumContact displayName], @"identityName",
			[adiumContact name],		@"identityEmailAddress",
			[adiumAccount name],		@"account",
			[adiumService name],		@"serviceName",
			[adiumChat dateOpened],		@"contextDate",
			@"Chat",					@"interactionType",
			@"with",					@"interactionPreposition",
			nil];
}

@end
