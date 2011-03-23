//
//  iChatContextContentProvider.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "iChatContextContentProvider.h"
#import "iChat.h"

@implementation iChatContextContentProvider

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
		application = [[SBApplication applicationWithBundleIdentifier:@"com.apple.iChat"] retain];
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
	
	NSArray *activeChats = [[application chats] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]];
	if([activeChats count] == 0) {
		TRACE(@"No active chats detected...");
		return nil;
	}

	iChatChat *activeChat = [activeChats objectAtIndex:0];
	iChatService *chatService = [activeChat service];

	NSArray *chatBuddies = [activeChat participants];
	iChatBuddy *buddy = [chatBuddies objectAtIndex:0];
	
//	
//	// TODO
//	// Build identity dict
//	// Build additional content dict
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[buddy name],			@"identityName",
			[buddy handle],			@"identityEmailAddress",
			[chatService name],		@"serviceName",
			@"Chat",				@"interactionType",
			@"with",				@"interactionPreposition",
			nil];
}
@end
