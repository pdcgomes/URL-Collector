//
//  SAPOPunyAPI.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLShorteningService;

@interface URLShortener : NSObject 
{
	URLShorteningService	*service;
	NSObject				*delegate;
}

@property (nonatomic, assign) NSObject *delegate;

+ (BOOL)isValidURL:(NSString *)URL;
+ (BOOL)conformsToRFC1808:(NSString *)URL;
+ (NSArray *)supportedShorteningServices;

- (id)initWithServiceKey:(NSString *)serviceKey;
- (void)shortenURL:(NSString *)URL;

@end

@interface NSObject(URLShortenerDelegate)

- (void)URLShortener:(URLShortener *)shortener didShortenURL:(NSString *)URL withResult:(NSString *)shortURL;
- (void)URLShortener:(URLShortener *)shortener didFailWithError:(NSError *)error;

@end
