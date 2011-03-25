//
//  URLCollectorContentClassifier.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class URLCollectorElement;

@protocol URLCollectorContentClassifierDelegate <NSObject>

@required

- (void)classificationForElement:(URLCollectorElement *)element didFinishWithResult:(NSDictionary *)classification;
- (void)classificationForElement:(URLCollectorElement *)element didFailWithError:(NSError *)error;

@end

@interface URLCollectorContentClassifier : NSObject 
{
	NSMutableDictionary *classifiableElements; // element => delegate
	NSOperationQueue	*classificationOperationQueue;
}

+ (id)sharedInstance;

- (void)classifyElement:(URLCollectorElement *)element delegate:(NSObject<URLCollectorContentClassifierDelegate> *)delegate;
- (void)cancelClassificationForElement:(URLCollectorElement *)element;

extern NSString *const URLClassificationMIMETypeKey;
extern NSString *const URLClassificationTitleKey;
extern NSString *const URLClassificationDescriptionKey;
extern NSString *const URLClassificationKeywordsKey;
extern NSString *const URLClassificationImageKey;

@end

