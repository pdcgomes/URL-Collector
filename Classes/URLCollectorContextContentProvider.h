//
//  URLCollectorContextContentProvider.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/15/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBApplication;

@interface URLCollectorContextContentProvider : NSObject 
{

}

+ (NSString *)applicationIdentifier;
- (NSDictionary *)extractContent;

@end
