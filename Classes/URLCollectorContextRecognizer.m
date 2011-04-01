//
//  ContextRecognizer.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorContextRecognizer.h"
#import "URLCollectorContext.h"

#import "SKObjectSingleton.h"

#import "AddressBookContextContentProvider.h"
#import "AdiumContextContentProvider.h"
#import "ChromeContextContentProvider.h"
#import "GenericContextContentProvider.h"
#import "iCalContextContentProvider.h"
#import "iChatContextContentProvider.h"
#import "MailContextContentProvider.h"
#import "SafariContextContentProvider.h"
#import "XcodeContextContentProvider.h"

// TODO
// Add Skype
// Add Firefox
// ...

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

- (URLCollectorContext *)guessContextFromActiveApplication
{
	return [self guessContextFromApplication:[[NSWorkspace sharedWorkspace] activeApplication]];
}

- (URLCollectorContext *)guessContextFromApplication:(NSDictionary *)applicationInfo
{
	NSAssert([applicationInfo containsKey:@"NSApplicationBundleIdentifier"], @"Missing <NSApplicationBundleIdentifier> key from applicationInfo dictionary!");
			  
	Class contentProviderClass = [self contextContentProviderClassForBundleIdentifier:[applicationInfo objectForKey:@"NSApplicationBundleIdentifier"]];
	
	URLCollectorContextContentProvider *contentProvider = [[contentProviderClass alloc] init];
	NSDictionary *contextDict = [contentProvider extractContent];
	[contentProvider release];
	
	return [[[URLCollectorContext alloc] initWithIdentity:contextDict fromApplication:applicationInfo] autorelease];
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)isRecognizedApplication:(NSString *)bundleIdentifier
{
	if(supportedApplications == nil) {
		supportedApplications = [[NSDictionary alloc] initWithObjectsAndKeys:
								 // Apple applications
								 [AddressBookContextContentProvider class],	[AddressBookContextContentProvider applicationIdentifier],
								 [iCalContextContentProvider class],		[iCalContextContentProvider applicationIdentifier],
								 [iChatContextContentProvider class],		[iChatContextContentProvider applicationIdentifier],
								 [MailContextContentProvider class],		[MailContextContentProvider applicationIdentifier],
								 [SafariContextContentProvider class],		[SafariContextContentProvider applicationIdentifier],
								 [XcodeContextContentProvider class],		[XcodeContextContentProvider applicationIdentifier],
								 // Non-apple
								 [AdiumContextContentProvider class],		[AdiumContextContentProvider applicationIdentifier],
								 [ChromeContextContentProvider class],		[ChromeContextContentProvider applicationIdentifier],
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
