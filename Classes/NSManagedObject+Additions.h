//
//  NSManagedObjectAdditions.h
//  WideScope_Farmacias_iPhone
//
//  Created by Pedro Gomes on 11/4/09.
//  Copyright 2009 SAPO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSManagedObject(Additions)

- (BOOL)trySetProperty:(SEL)propertySetter withValue:(NSString *)value;
- (BOOL)trySetProperty:(SEL)propertySetter withValue:(id)value transform:(SEL)transformSelector;
- (BOOL)trySetPropertyForKey:(NSString *)keyPath withValue:(id)value transform:(SEL)transformSelector;
- (BOOL)trySetNumberProperty:(SEL)selector withValue:(NSString *)value formatter:(NSNumberFormatter *)numberFormatter;
- (BOOL)isNilValue:(id)value;

- (NSManagedObject *)duplicate;

@end
