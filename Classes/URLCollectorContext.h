//
//  URLCollectorElementSource.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorContextIdentity;

@interface URLCollectorContext : NSObject <NSCoding>
{	
	NSString	*contextName;	// Name that uniquely identifies this context
	NSString	*contextURL;	// Reference URL to this context
	NSImage		*contextImage;	// Image representation for the context
	NSDate		*contextDate;	// Date
	
	NSString	*interaction;
	URLCollectorContextIdentity	*contextIdentity; // The generic identity that provided the context (i.e., address book contact, twitter, generic person; blog, website, etc.)
	NSDictionary				*contextApplication; // Information for the application that provided this context
}

@property (nonatomic, readonly) NSString *contextName;
@property (nonatomic, readonly) NSString *contextURL;
@property (nonatomic, readonly) NSString *interaction;
@property (nonatomic, readonly) NSDate *contextDate;

@property (nonatomic, readonly) URLCollectorContextIdentity *contextIdentity;
@property (nonatomic, readonly) NSDictionary *contextApplication;

// Convenience properties as an abstraction over the contextApplication dictionary
@property (nonatomic, readonly) NSString *applicationName;
@property (nonatomic, readonly) NSString *applicationBundleIdentifier;
@property (nonatomic, readonly) NSImage *applicationIcon;

@property (nonatomic, readonly) NSString *contextInfoLine;
@property (nonatomic, readonly) NSString *relativeDate;

- (id)initWithIdentity:(NSDictionary *)identityInfo fromApplication:(NSDictionary *)applicationInfo;

@end
