//
//  NSString+Additions.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 4/1/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "NSString+Additions.h"
#import "RegexKitLite.h"

@implementation NSString(Additions)

#define URL_MATCHING_PATTERN @"(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

- (BOOL)isValidURL
{
	return [self isMatchedByRegex:URL_MATCHING_PATTERN];
}

@end
