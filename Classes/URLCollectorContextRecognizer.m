//
//  ContextRecognizer.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorContextRecognizer.h"
#import "SKObjectSingleton.h"

#import "AddressBook.h"
#import "Adium.h"
#import "iCal.h"
#import "iChat.h"
#import "Mail.h"
#import "Safari.h"
#import "Xcode.h"

@interface URLCollectorContextRecognizer(Private)

- (Class)contextRecognizerClassForBundleIdentifier:(NSString *)bundleIdentifier;
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
	return [self guessContextWithApplication:[[NSWorkspace sharedWorkspace] activeApplication]];
}

- (NSDictionary *)guessContextWithApplication:(NSDictionary *)applicationInfo
{
	
	//NSString *bundleIdentifier = [applicationInfo objectForKey:@"NSApplicationBundleIdentifier"];
	return nil;
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)isRecognizedApplication:(NSString *)bundleIdentifier
{
	if(supportedApplications == nil) {
		supportedApplications = [[NSDictionary alloc] initWithObjectsAndKeys: // Replace objects with the appropriate classes (when they're available)
								 // Apple applications
								 @"AddressBookContextRecognizer",	@"com.apple.AddressBook",
								 @"iCalContextRecognizer",			@"com.apple.iCal",
								 @"iChatContextRecognizer",			@"com.apple.iChat",
								 @"MailContextRecognizer",			@"com.apple.mail",
								 @"SafariContextRecognizer",		@"com.apple.Safari",
								 @"XcodeContextRecognizer",			@"com.apple.Xcode",
								 // Non-apple
								 @"AdiumContextRecognizer",			@"com.adiumX.adiumX",
								 nil];
	}
	return [supportedApplications containsKey:bundleIdentifier];
}

- (Class)contextRecognizerClassForBundleIdentifier:(NSString *)bundleIdentifier
{
	if([self isRecognizedApplication:bundleIdentifier]) {
		return NSClassFromString([supportedApplications objectForKey:bundleIdentifier]);
	}
	else {
		return NSClassFromString(@"DefaultContextRecognizer"); // Replace with actual class
	}
}

@end
