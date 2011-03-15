//
//  URLCollectorContextIdentity.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface URLCollectorContextIdentity : NSObject 
{
	NSInteger	identityType;
	NSString	*identityName;
	NSString	*identityURL;
	NSString	*identityEmailAddress;
	NSImage		*identityImageRepresentation;
}

@property (nonatomic, readwrite) NSInteger identityType;
@property (nonatomic, copy) NSString *identityName;
@property (nonatomic, copy) NSString *identityURL;
@property (nonatomic, copy) NSString *identityEmailAddress;
@property (nonatomic, retain) NSImage *identityImageRepresentation;

- (id)initWithDictionary:(NSDictionary *)dictionaryRepresentation;

@end

extern NSString *const URLCollectorContextIdentityTypeKey;
extern NSString *const URLCollectorContextIdentityNameKey;
extern NSString *const URLCollectorContextIdentityURLKey;
extern NSString *const URLCollectorContextIdentityEmailAddressKey;
extern NSString *const URLCollectorContextIdentityImageKey;
