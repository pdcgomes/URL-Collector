//
//  ClassifyURLOperation.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorClassifyURLOperation.h"
#import "URLCollectorContentClassifier.h"
#import "URLCollectorElement.h"
#import "TFHpple.h"

enum {
	ClassiftyURLStateInitialized = 0,
	ClassiftyURLStateLoadingURL,
	ClassiftyURLStateParsingMetadata,
	ClassiftyURLStateDerivingContext,
	ClassiftyURLStateFinished,
};

@interface URLCollectorClassifyURLOperation()

- (void)executeState;

- (void)startClassification;
- (void)extractContentType;
- (void)extractMetadata;

- (void)reportSuccess;
- (void)reportError:(NSError *)error;

@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;

@end

@implementation URLCollectorClassifyURLOperation

@synthesize element;
@synthesize isCancelled = canceled;
@synthesize isExecuting = executing;
@synthesize isFinished = finished;

@synthesize delegate;

#pragma mark - 
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[connection cancel];
	
	[element release];
	[classification release];
	[connection release];
	
	[super dealloc];
}

- (id)initWithElement:(URLCollectorElement *)theElement
{
	if((self = [super init])) {
		element = [theElement retain];
		classification = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark NSOperation

- (void)start
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	self.isExecuting = YES;
	self.isFinished = NO;
	
	[self main];
	
	self.isExecuting = NO;
	self.isFinished = YES;
	
	[pool release];
}

- (void)main
{
	NSRunLoop *runLoop = [[NSRunLoop currentRunLoop] retain];
	state = ClassiftyURLStateInitialized;
	[self executeState];
	
	[self startClassification];
	
	while(!self.isFinished && ![self isCancelled]) {
		[runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
	}
	
	[runLoop release];
}

- (void)cancel
{
	self.isCancelled = YES;
}

- (BOOL)isConcurrent
{
	return YES;
}

#pragma mark -
#pragma mark Private Methods

- (void)reportSuccess
{
	SK_ASSERT_MAIN_THREAD;
	
	if([self.delegate respondsToSelector:@selector(classifyURLOperation:didFinishWithResult:)]) {
		[self.delegate classifyURLOperation:self didFinishWithResult:classification];
	}
}

- (void)reportError:(NSError *)error
{
	SK_ASSERT_MAIN_THREAD;

	if([self.delegate respondsToSelector:@selector(classifyURLOperation:didFailWithError:)]) {
		[self.delegate classifyURLOperation:self didFailWithError:error];
	}
}

- (void)executeState
{
//	switch(state) 
//	{
//		case ClassiftyURLStateInitialized:
//			[self startClassification];
//			break;
//			
//		case ClassiftyURLStateLoadingURL:
//			[self extractMetadata];
//			break;
//			
//		case ClassiftyURLStateParsingMetadata:
//			
//			break;
//			
//		case ClassiftyURLStateDerivingContext:
//			
//			break:
//			
//		case ClassiftyURLStateFinished:
//			
//			break;
//	}
}

- (void)startClassification
{
	[self extractContentType];
}

- (void)extractContentType
{
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:element.URL]];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];
	
	[connection start];
}

- (void)extractMetadata
{
	// Decode the received data
	// Ensure it's a webpage
	// Extract: title, metadata, keywords, favicon, etc.
	// Think about deriving context from other sources (google social API?)
	TFHpple *HTMLParser = [[TFHpple alloc] initWithHTMLData:connectionData];
	
	TFHppleElement *titleElement = [[HTMLParser search:@"//title"] lastObject];
	if(titleElement) {
		NSString *title = [titleElement content];
		TRACE(@"title: %@", title);
		[classification setObject:title forKey:URLClassificationTitleKey];
	}
	
	NSDictionary *interestingMetaTags = [[NSDictionary alloc] initWithObjectsAndKeys:
										 URLClassificationDescriptionKey,	@"description",
										 URLClassificationKeywordsKey,		@"keywords",
										 nil];
	
	NSArray *metaElements = [HTMLParser search:@"//meta"];
	for(TFHppleElement *metaElement in metaElements) {
		NSString *attributeName = [metaElement objectForKey:@"name"];
		if(attributeName && [interestingMetaTags containsKey:attributeName]) {
			NSString *attributeValue = [metaElement objectForKey:@"content"];
			[classification setObject:attributeValue forKey:[interestingMetaTags objectForKey:attributeName]];
		}
		TRACE(@"name = %@, content = %@", [metaElement objectForKey:@"name"], [metaElement objectForKey:@"content"]);
	}
	[interestingMetaTags release];
	[HTMLParser release];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

#define MAX_EXPECTED_CONTENT_LENGTH (1024 * 512)
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	NSString *MIMEType = [response MIMEType];
	TRACE(@"Mime type: %@", MIMEType);
	[classification setObject:MIMEType forKey:URLClassificationMIMETypeKey];
	
	if(NSNotFound == [MIMEType rangeOfString:@"html"].location) { // rough method to test if it's an html document or some other file 
		[classification setObject:[response suggestedFilename] forKey:URLClassificationTitleKey];
		[theConnection cancel]; // we don't want to continue downloading. The mime type will be used to display a representation of the (probable) file type, and the suggested filename will be used as the title
		self.isFinished = YES;
	}
	else if([response expectedContentLength] > MAX_EXPECTED_CONTENT_LENGTH) {
		WARN(@"HTML content exceeds maximum supported length. TODO: implement proper action"); // maybe download part (up to the max limit) of the document and attempt extraction of what's available
		[theConnection cancel];
		self.isFinished = YES;
	}
	else {
		INFO(@"Mime type declared as text/html. Will now load the remaining data to attempt parsing/content extraction.");
	}
	
	// Determine if it's a regular page or some other content type -- we'll use the guessed MIME type to make these decisions
	// If it's a webpage, continue loading the request (we want to extract further context from the page)
	// Else, simply cancel the request and finish the operation -- we'll report back the content type and eventually the file name
	
	// Should also look at the expectedContentLength -- if it's above a certain threshold, stop loading the data 
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	if(!connectionData) {
		connectionData = [[NSMutableData alloc] init];
	}
	[connectionData appendData:data];
}

#define MAX_UPLOAD_RETRIES 3
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	if(retries < MAX_UPLOAD_RETRIES) {
		retries++;
		[connectionData release], connectionData = nil;
		[theConnection start];
		return;
	}
	
	if(theConnection == connection) {
		[connection release];
		connection = nil;
	}
	[self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	TRACE(@"Finished loading html data. Will now attempt to parse it...");
	[self extractMetadata];
	[self performSelectorOnMainThread:@selector(reportSuccess) withObject:nil waitUntilDone:YES];
	self.isFinished = YES;
}

@end
