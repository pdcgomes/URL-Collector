//
//  URLCollectorContentClassifier.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLCollectorContentClassifier.h"
#import "URLCollectorClassifyURLOperation.h"
#import "SKObjectSingleton.h"

NSString *const URLClassificationMIMETypeKey	= @"URLClassificationMIMEType";
NSString *const URLClassificationTitleKey		= @"URLClassificationTitle";
NSString *const URLClassificationDescriptionKey	= @"URLClassificationDescription";
NSString *const URLClassificationKeywordsKey	= @"URLClassificationKeywords";
NSString *const URLClassificationImageKey		= @"URLClassificationImage";

@implementation URLCollectorContentClassifier

#pragma mark -
#pragma mark Dealloc and Initialization

SK_OBJECT_SINGLETON_BOILERPLATE(URLCollectorContentClassifier, sharedInstance);

- (id)init
{
	if((self = [super init])) {
		classifiableElements = CreateNonRetainingDictionary(); // this ensures the completion targets (effectively delegates) are never retained
		classificationOperationQueue = [[NSOperationQueue alloc] init];
		[classificationOperationQueue setMaxConcurrentOperationCount:5];
	}
	return self;
}
#pragma mark -
#pragma mark Public Methods

- (void)classifyElement:(URLCollectorElement *)element delegate:(NSObject<URLCollectorContentClassifierDelegate> *)delegate
{
	NSParameterAssert(delegate != nil);
	
	if([classifiableElements containsKey:element]) {
		[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.DuplicateClassifiableElement" 
								 reason:SKStringWithFormat(@"Element <%@> is already in the current queue pending classification", element) 
							   userInfo:nil] raise];
	}
	
	[classifiableElements setObject:delegate forKey:element];
	
	URLCollectorClassifyURLOperation *operation = [[URLCollectorClassifyURLOperation alloc] initWithElement:element];
	[operation setDelegate:self];
	[classificationOperationQueue addOperation:operation];
	[operation release];
}

- (void)cancelClassificationForElement:(URLCollectorElement *)element
{
	NSArray *operations = [[classificationOperationQueue operations] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"element = %@", element]];
	[operations makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark -
#pragma mark URLCollectorClassifyURLOperationDelegate

- (void)classifyURLOperation:(URLCollectorClassifyURLOperation *)operation didFinishWithResult:(NSDictionary *)classification
{
	NSAssert([classifiableElements containsKey:operation.element], @"");
	
	NSObject<URLCollectorContentClassifierDelegate> *delegate = [classifiableElements objectForKey:operation.element];
	if([delegate respondsToSelector:@selector(classificationForElement:didFinishWithResult:)]) {
		[delegate classificationForElement:operation.element didFinishWithResult:classification];
	}
	[classifiableElements removeObjectForKey:operation.element];
}

- (void)classifyURLOperation:(URLCollectorClassifyURLOperation *)operation didFailWithError:(NSError *)error
{
	NSAssert([classifiableElements containsKey:operation.element], @"");

	NSObject<URLCollectorContentClassifierDelegate> *delegate = [classifiableElements objectForKey:operation.element];
	if([delegate respondsToSelector:@selector(classificationForElement:didFailWithError:)]) {
		[delegate classificationForElement:operation.element didFailWithError:error];
	}
	[classifiableElements removeObjectForKey:operation.element];
}

- (void)classifyURLOperationDidCancel:(URLCollectorClassifyURLOperation *)operation
{
	[classifiableElements removeObjectForKey:operation.element];
}

@end
