/*
 *  Macros.h
 *  GamesOnDemandClient
 *
 *  Created by Pedro Gomes on 12/15/10.
 *  Copyright 2010 SAPO. All rights reserved.
 *
 */

#define SKArrayLength(x) (sizeof(x)/sizeof(*(x)))

#define SKStringWithFormat(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]
#define SKStringWithFormat2(format, value) [NSString stringWithFormat:format, value]
#define SKStringCompare(stringA, stringB) [stringA isEqualToString:stringB]

#define SKConditional(condition, trueExpression, falseExpression) condition ? trueExpression : falseExpression
#define IsEmptyValue(_value_) ((id)_value_ == [NSNull null] || !(id)_value_)
#define IsEmptyString(_string_) (!_string_ || (id)_string_ == [NSNull null] || [_string_ length] == 0)
#define SKSafeString(_string_) (!IsEmptyString(_string_) ? _string_ : @"")
#define SKSafeStringWithDefault(_string_, _emptyString_) (!IsEmptyString(_string_) ? _string_ : _emptyString_)

#define SKSetterOverride(_ivar_name_, _new_var_name_) \
if(_ivar_name_ == _new_var_name_) return; \
[_ivar_name_ release]; \
_ivar_name_ = nil; \
_ivar_name_ = [_new_var_name_ retain]

#define SKSafeRelease(_ivar_name_) { [_ivar_name_ release]; _ivar_name_ = nil; }
#define SKSafeDelegate(_delegate_, _selector_) if([_delegate_ respondsToSelector:_selector_]) { [_delegate_ performSelector:_selector_]; }

#define SKLocalizedString(string) NSLocalizedString(string, nil)

#define SK_ASSERT_MAIN_THREAD NSAssert([NSThread currentThread] == [NSThread mainThread], @"The notification was not handled on the MainThread")

//https://github.com/rsms/chromium-tabs/blob/master/src/third_party/gtm-subset/GTMDefines.h
#define SK_NSSTRINGIFY_INNER(x) @#x
#define SK_NSSTRINGIFY(x) SK_NSSTRINGIFY_INNER(x)


//Calendar and DateTime Constants

#define CALENDAR_UNIT_FLAGS NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit

#define ONE_MINUTE (60.0)
#define ONE_HOUR   (60.0 * ONE_MINUTE)
#define ONE_DAY    (24.0 * ONE_HOUR)
#define ONE_WEEK   (7.0 * ONE_DAY)
#define ONE_MONTH  (30.5 * ONE_DAY)
#define ONE_YEAR   (365.0 * ONE_DAY)

/// Timing macros
/// Adapted from: Stephan Burlot (http://blog.coriolis.ch/2009/01/05/macros-for-xcode/)

#define START_TIMER NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#define END_TIMER(msg) 	NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate]; TRACE(@"%@ Time = %f", msg, stop-start);

/// This macro implements the various methods needed to make a safe singleton.
//
/// This Singleton pattern was taken from:
/// http://developer.apple.com/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/chapter_3_section_10.html
///
/// The macro was adapted from the Google Tookit Mac (GTM)
///
/// Sample usage:
///
/// SK_OBJECT_SINGLETON_BOILERPLATE(SingletonManagerClass, sharedInstance)
/// (with no trailing semicolon)
///

#define SK_OBJECT_SINGLETON_BOILERPLATE(_object_name_, _shared_obj_name_) \
static _object_name_ *z##_shared_obj_name_ = nil;  \
+ (_object_name_ *)_shared_obj_name_ {             \
@synchronized(self) {                            \
if (z##_shared_obj_name_ == nil) {             \
/* Note that 'self' may not be the same as _object_name_ */                               \
/* first assignment done in allocWithZone but we must reassign in case init fails */      \
z##_shared_obj_name_ = [[self alloc] init];                                               \
NSAssert((z##_shared_obj_name_ != nil), @"didn't catch singleton allocation");       \
}                                              \
}                                                \
return z##_shared_obj_name_;                     \
}                                                  \
+ (id)allocWithZone:(NSZone *)zone {               \
@synchronized(self) {                            \
if (z##_shared_obj_name_ == nil) {             \
z##_shared_obj_name_ = [super allocWithZone:zone]; \
return z##_shared_obj_name_;                 \
}                                              \
}                                                \
\
/* We can't return the shared instance, because it's been init'd */ \
NSAssert(NO, @"use the singleton API, not alloc+init");        \
return nil;                                      \
}                                                  \
- (id)retain {                                     \
return self;                                     \
}                                                  \
- (NSUInteger)retainCount {                        \
return NSUIntegerMax;                            \
}                                                  \
- (void)release {                                  \
}                                                  \
- (id)autorelease {                                \
return self;                                     \
}                                                  \
- (id)copyWithZone:(NSZone *)zone {                \
return self;                                     \
}                                                  \

#define NSIMAGE(imageName) [NSImage imageNamed:imageName]

#define DEFAULT_RETRY_COUNT	3
#define DEFAULT_RETRY_SLEEP 500000

#define RGBACOLOR(R,G,B,A) ([NSColor colorWithDeviceRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A])
#define RGBCOLOR(R,G,B) (RGBACOLOR(R,G,B,1.0))

// For more info go here: http://gcc.gnu.org/onlinedocs/gcc/Constructing-Calls.html#Constructing-Calls
#define RETRY(maxRetryCount) do { \
static NSInteger __retries = -1; \
if(__retries == -1) { \
__retries = (maxRetryCount - 1);\
}\
if(__retries > 0) { \
WARN(@"***** PERFORMING RETRY #%d...", __retries);\
__retries--; \
usleep(DEFAULT_RETRY_SLEEP);\
NSUInteger argSize = [[self methodSignatureForSelector:_cmd] frameLength];\
void *args = __builtin_apply_args();\
void *result = __builtin_apply((void (*) (void))[self methodForSelector:_cmd], args, argSize);\
__builtin_return(result);\
}\
else {\
__retries = -1;\
return nil;\
}	\
}\
while(0) \

#define RETRY_VOID(maxRetryCount) do { \
static NSInteger __retries = -1; \
if(__retries == -1) { \
__retries = (maxRetryCount - 1);\
}\
if(__retries > 0) { \
WARN(@"***** PERFORMING RETRY #%d...", __retries);\
__retries--; \
usleep(DEFAULT_RETRY_SLEEP);\
NSUInteger argSize = [[self methodSignatureForSelector:_cmd] frameLength];\
void *args = __builtin_apply_args();\
void *result = __builtin_apply((void (*) (void))[self methodForSelector:_cmd], args, argSize);\
__builtin_return(result);\
}\
else {\
__retries = -1;\
return;\
}\
}\
while(0)

#define RETRY_RETURN(maxRetryCount, returnData) do { \
static NSInteger __retries = -1; \
if(__retries == -1) { \
__retries = (maxRetryCount - 1);\
}\
if(__retries > 0) { \
WARN(@"***** PERFORMING RETRY #%d...", __retries);\
__retries--; \
usleep(DEFAULT_RETRY_SLEEP);\
NSUInteger argSize = [[self methodSignatureForSelector:_cmd] frameLength];\
void *args = __builtin_apply_args();\
void *result = __builtin_apply((void (*) (void))[self methodForSelector:_cmd], args, argSize);\
__builtin_return(result);\
}\
else {\
__retries = -1;\
return returnData;\
}\
}\
while(0)
