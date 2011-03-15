//
//  ContextRecognizer.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorContextRecognizer.h"
#import "SKObjectSingleton.h"

#import "AddressBookContextContentProvider.h"
#import "AdiumContextContentProvider.h"
#import "GenericContextContentProvider.h"
#import "iCalContextContentProvider.h"
#import "iChatContextContentProvider.h"
#import "MailContextContentProvider.h"
#import "SafariContextContentProvider.h"
#import "XcodeContextContentProvider.h"

@interface URLCollectorContextRecognizer(Private)

- (Class)contextContentProviderClassForBundleIdentifier:(NSString *)bundleIdentifier;
- (BOOL)isRecognizedApplication:(NSString *)bundleIdentifier;

@end

@implementation URLCollectorContextRecognizer

SK_OBJECT_SINGLETON_BOILERPLATE(URLCollectorContextRecognizer, sharedInstance);

- (void)dealloc
{
	[supportedApplications release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

- (void)startAutomaticContextRecognition
{
	
}

- (void)stopAutomaticContextRecognition
{
	
}

- (NSDictionary *)guessContextFromActiveApplication
{
	return [self guessContextFromApplication:[[NSWorkspace sharedWorkspace] activeApplication]];
}

- (NSDictionary *)guessContextFromApplication:(NSDictionary *)applicationInfo
{
	NSAssert([applicationInfo containsKey:@"NSApplicationBundleIdentifier"], @"Missing <NSApplicationBundleIdentifier> key from applicationInfo dictionary!");
			  
	Class contentProviderClass = [self contextContentProviderClassForBundleIdentifier:[applicationInfo objectForKey:@"NSApplicationBundleIdentifier"]];
	
	URLCollectorContextContentProvider *contentProvider = [[contentProviderClass alloc] init];
	[contentProvider extractContent];
	[contentProvider release];
	//NSString *bundleIdentifier = [applicationInfo objectForKey:@"NSApplicationBundleIdentifier"];
	return nil;
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)isRecognizedApplication:(NSString *)bundleIdentifier
{
	if(supportedApplications == nil) {
		supportedApplications = [[NSDictionary alloc] initWithObjectsAndKeys:
								 // Apple applications
								 [AddressBookContextContentProvider class],	@"com.apple.AddressBook",
								 [iCalContextContentProvider class],		@"com.apple.iCal",
								 [iChatContextContentProvider class],		@"com.apple.iChat",
								 [MailContextContentProvider class],		@"com.apple.mail",
								 [SafariContextContentProvider class],		@"com.apple.Safari",
								 [XcodeContextContentProvider class],		@"com.apple.Xcode",
								 // Non-apple
								 [AdiumContextContentProvider class],		@"com.adiumX.adiumX",
								 nil];
	}
	return [supportedApplications containsKey:bundleIdentifier];
}

- (Class)contextContentProviderClassForBundleIdentifier:(NSString *)bundleIdentifier
{
	if([self isRecognizedApplication:bundleIdentifier]) {
		return [supportedApplications objectForKey:bundleIdentifier];
	}
	else {
		return [GenericContextContentProvider class];
	}
}

@end
