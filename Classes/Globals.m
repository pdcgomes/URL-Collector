//
//  Globals.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/24/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "Globals.h"

static const void *RetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void ReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray *CreateNonRetainingArray() 
{
	CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
	callbacks.retain = RetainNoOp;
	callbacks.release = ReleaseNoOp;
	return (NSMutableArray *)CFArrayCreateMutable(nil, 0, &callbacks);
}

NSMutableDictionary *CreateNonRetainingDictionary() 
{
	CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
	CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
	callbacks.retain = RetainNoOp;
	callbacks.release = ReleaseNoOp;
	return (NSMutableDictionary *)CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks);
}
