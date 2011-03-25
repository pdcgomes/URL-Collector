//
//  ClassifyURLOperation.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorElement;

@interface URLCollectorClassifyURLOperation : NSOperation
{
	URLCollectorElement	*element;
	NSMutableDictionary	*classification;

	BOOL				cancelled;
	BOOL				executing;
	BOOL				finished;
	
	NSURLConnection		*connection;
	NSMutableData		*connectionData;

	NSObject			*delegate;
	
	NSUInteger			retries;
	NSUInteger			state;
}

@property (nonatomic, readonly) URLCollectorElement *element;
@property (nonatomic, readonly) BOOL isCancelled;
@property (nonatomic, readonly) BOOL isExecuting;
@property (nonatomic, readonly) BOOL isFinished;
@property (nonatomic, assign) NSObject *delegate;

- (id)initWithElement:(URLCollectorElement *)element;

@end

@interface NSObject(URLCollectorClassifyURLOperationDelegate)

- (void)classifyURLOperation:(URLCollectorClassifyURLOperation *)operation didFinishWithResult:(NSDictionary *)classification;
- (void)classifyURLOperationDidCancel:(URLCollectorClassifyURLOperation *)operation;
- (void)classifyURLOperation:(URLCollectorClassifyURLOperation *)operation didFailWithError:(NSError *)error;

@end