//
//  NSBundle+Additions.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/14/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBundle(PathAdditions)

- (NSString *)applicationSupportPath;
- (NSString *)applicationCachesPath;

@end
