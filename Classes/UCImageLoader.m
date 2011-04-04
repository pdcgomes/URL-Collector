//
//  NSImage+AsyncLoading.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 4/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "UCImageLoader.h"
#import "GTMHTTPFetcher.h"

@implementation UCImageLoader

@synthesize delegate;
@synthesize imageURL;
@synthesize image;

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[fetcher stopFetching];
	delegate = nil;
	
	[image release];
	[fetcher release];
	[imageURL release];
	
	[super dealloc];
}

- (id)initWithImageURL:(NSString *)theImageURL delegate:(NSObject *)theDelegate
{
	if((self = [super init])) {
		imageURL = [theImageURL copy];
		delegate = theDelegate;
	}
	return self;
}
#pragma mark -
#pragma mark Public Methods

- (void)load
{
	if([fetcher isFetching]) {
		WARN(@"Image <%@> is already loading!", imageURL);
		return;
	}
	if(fetcher) {
		[fetcher release];
		fetcher = nil;
	}
	if(image) {
		[image release];
		image = nil;
	}
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURL]];
	fetcher = [[GTMHTTPFetcher alloc] initWithRequest:request];
	[fetcher beginFetchWithDelegate:self didFinishSelector:@selector(fetcher:finishedWithData:error:)];
	[request release];
}

- (void)cancel
{
	[fetcher stopFetching];
}

#pragma mark -
#pragma mark GTMHTTPFetcherDelegate

- (void)fetcher:(GTMHTTPFetcher *)theFetcher finishedWithData:(NSData *)data error:(NSError *)error
{
	if(error != nil) {
		if([self.delegate respondsToSelector:@selector(imageLoader:didFailWithError:)]) {
			[self.delegate imageLoader:self didFailWithError:error];
		}
	}
	else {
		image = [[NSImage alloc] initWithData:data];
		if([self.delegate respondsToSelector:@selector(imageLoader:didFinishLoadingImage:)]) {
			[self.delegate imageLoader:self didFinishLoadingImage:image];
		}
	}
}

@end
