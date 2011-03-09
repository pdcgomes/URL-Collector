//
//  URLShorteningService.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GTMHTTPFetcher.h"

@protocol URLShorteningService <NSObject>

- (void)shortenURL:(NSString *)URL;
- (NSString *)requestURLWithURL:(NSString *)URL;
- (NSString *)processResponse:(NSData *)responseData error:(NSError **)error;

@end

@interface URLShorteningService : NSObject <URLShorteningService>
{
	GTMHTTPFetcher	*fetcher;
	NSObject		*delegate;
	NSString		*URL;
}

@property (nonatomic, assign) NSObject *delegate;

- (void)shortenURL:(NSString *)URL;
- (NSString *)requestURLWithURL:(NSString *)URL;
- (NSString *)processResponse:(NSData *)responseData error:(NSError **)error;

@end

@interface NSObject(URLShorteningServiceDelegate)

- (void)shorteningService:(URLShorteningService *)service didShortenURL:(NSString *)URL withResult:(NSString *)shortURL;
- (void)shorteningService:(URLShorteningService *)service didFailWithError:(NSError *)error;

@end