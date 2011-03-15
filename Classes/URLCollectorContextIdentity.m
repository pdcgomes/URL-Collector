//
//  URLCollectorContextIdentity.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorContextIdentity.h"

NSString *const URLCollectorContextIdentityTypeKey			= @"identityType";
NSString *const URLCollectorContextIdentityNameKey			= @"identityName";
NSString *const URLCollectorContextIdentityURLKey			= @"identityURL";
NSString *const URLCollectorContextIdentityEmailAddressKey	= @"identityEmailAddress";
NSString *const URLCollectorContextIdentityImageKey			= @"identityImageRepresentation";

@implementation URLCollectorContextIdentity

@synthesize identityType;
@synthesize identityName;
@synthesize identityURL;
@synthesize identityEmailAddress;
@synthesize identityImageRepresentation;

#pragma mark - 
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[identityName release];
	[identityURL release];
	[identityEmailAddress release];
	[identityImageRepresentation release];
	
	[super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)dictionaryRepresentation;
{
	if((self = [super init])) {
		
	}
	return self;
}

@end
