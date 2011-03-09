//
//  NSDictionary+Additions.m
//  GamesOnDemandClient
//
//  Created by Pedro Gomes on 1/17/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "NSDictionary+Additions.h"


@implementation NSDictionary(Additions)

- (BOOL)containsKey:(id)key
{
	return CFDictionaryContainsKey((CFDictionaryRef)self, key);
}

@end
