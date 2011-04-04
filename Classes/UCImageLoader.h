//
//  NSImage+AsyncLoading.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 4/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GTMHTTPFetcher;

@interface UCImageLoader : NSObject <NSCopying>
{
	GTMHTTPFetcher	*fetcher;
	NSObject		*delegate;
	NSString		*imageURL;
	NSImage			*image;
}

@property (nonatomic, readonly) NSObject *delegate;
@property (nonatomic, readonly) NSString *imageURL;
@property (nonatomic, readonly) NSImage *image;

- (id)initWithImageURL:(NSString *)imageURL delegate:(NSObject *)target;
- (void)load;
- (void)cancel;

@end

@interface NSObject(UCImageLoaderDelegate)

- (void)imageLoader:(UCImageLoader *)imageLoader didFinishLoadingImage:(NSImage *)image;
- (void)imageLoader:(UCImageLoader *)imageLoader didFailWithError:(NSError *)error;

@end
