//
//  URLShorteningService.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLShorteningService.h"

@implementation URLShorteningService

@synthesize delegate;

- (void)dealloc
{
	[fetcher stopFetching];
	[fetcher release];
	[URL release];
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		
	}
	return self;
}

- (void)shortenURL:(NSString *)theURL
{
	if([fetcher isFetching]) {
		ERROR(@"Fetcher is currently busy.");
	}
	
	if(fetcher) {
		[fetcher release];
		fetcher = nil;
	}
	if(URL) {
		[URL release];
		URL = nil;
	}

	URL = [theURL copy];
	NSString *requestURL = [self requestURLWithURL:URL];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL]];
	fetcher = [[GTMHTTPFetcher fetcherWithRequest:request] retain];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetcher:finishedWithData:error:)];
	[request release];
}

- (NSString *)requestURLWithURL:(NSString *)URL
{
	WARN(@"***** SUBCLASSES MUST IMPLEMENT THIS METHOD *****");

	return nil;
}

#pragma mark -
#pragma mark GTMHTTPFetcherDelegate

- (void)fetcher:(GTMHTTPFetcher *)theFetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	NSString *shortURL = [self processResponse:data error:&error];
	if(shortURL) {
		if([self.delegate respondsToSelector:@selector(shorteningService:didShortenURL:withResult:)]) {
			[self.delegate shorteningService:self didShortenURL:URL withResult:shortURL];
		}
	}
	else {
		if([self.delegate respondsToSelector:@selector(shorteningService:didFailWithError:)]) {
			[self.delegate shorteningService:self didFailWithError:error];
		}
	}
}

- (NSString *)processResponse:(NSData *)responseData error:(NSError **)error
{
	WARN(@"***** SUBCLASSES MUST IMPLEMENT THIS METHOD *****");
	
	return nil;
}

@end
