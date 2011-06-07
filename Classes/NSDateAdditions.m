//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NSDateAdditions.h"

#define TT_RELEASE_SAFELY(_ivar_) \
do {				\
[_ivar_ release];	\
_ivar_ = nil;			\
} while(0);

NSLocale *AKCurrentLocale() 
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
	if(languages.count > 0) {
		NSString *currentLanguage = [languages objectAtIndex:0];
		return [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] autorelease];
	} else {
		return [NSLocale currentLocale];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
@implementation NSDate(DateAdditions)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate*)dateWithToday {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";

  NSString* formattedTime = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:formattedTime];
  TT_RELEASE_SAFELY(formatter);

  return date;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate*)dateAtMidnight {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";

  NSString* formattedTime = [formatter stringFromDate:self];
  NSDate* date = [formatter dateFromString:formattedTime];
  TT_RELEASE_SAFELY(formatter);

  return date;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatTime {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"h:mm a", @"Date format: 1:05 pm");
    formatter.locale = AKCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDate 
{
	static NSDateFormatter* formatter = nil;
	if (!formatter) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = NSLocalizedString(@"EEEE, LLLL d, YYYY", @"Date format: Monday, July 27, 2009");
		formatter.locale = AKCurrentLocale();
	}
	return [formatter stringFromDate:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);

  if (diff < TT_DAY) {
    return [self formatTime];

  } else if (diff < TT_5_DAYS) {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = NSLocalizedString(@"EEEE", @"Date format: Monday");
      formatter.locale = AKCurrentLocale();
    }
    return [formatter stringFromDate:self];

  } else {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = NSLocalizedString(@"M/d/yy", @"Date format: 7/27/09");
      formatter.locale = AKCurrentLocale();
    }
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDateTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);
  if (diff < TT_DAY) {
    return [self formatTime];

  } 
  else if (diff < TT_5_DAYS) {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = NSLocalizedString(@"EEE h:mm a", @"Date format: Mon 1:05 pm");
      formatter.locale = AKCurrentLocale();
    }
    return [formatter stringFromDate:self];

  } else {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = NSLocalizedString(@"MMM d h:mm a", @"Date format: Jul 27 1:05 pm");
      formatter.locale = AKCurrentLocale();
    }
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#define ELAPSED_CUTOFF_THRESHOLD (TT_DAY * 15.0)
- (NSString*)formatRelativeTime 
{
	NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
	if(elapsed <= 2) {
		return NSLocalizedString(@"just now", @"");
	}
	if(elapsed <= 20) {
		return NSLocalizedString(@"a few seconds ago", @"");
	} 
	else if(elapsed < TT_MINUTE) {
		return NSLocalizedString(@"less than a minute ago", @"");
	}
//	else if(elapsed < TT_MINUTE) {
//		int seconds = (int)(elapsed);
//		return [NSString stringWithFormat:NSLocalizedString(@"%d seconds ago", @""), seconds];
//		
//	} 
	else if(elapsed < 2 * TT_MINUTE) {
		return NSLocalizedString(@"about a minute ago", @"");
		
	} 
	else if(elapsed < TT_HOUR) {
		int mins = (int)(elapsed/TT_MINUTE);
		return [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", @""), mins];
		
	}
	else if(elapsed < TT_HOUR * 1.5) {
		return NSLocalizedString(@"about an hour ago", @"");
		
	}
	else if(elapsed < TT_DAY) {
		int hours = (int)((elapsed+TT_HOUR/2)/TT_HOUR);
		return [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", @""), hours];
		
	}
	else if(elapsed < ELAPSED_CUTOFF_THRESHOLD) {
		int days = (int)((elapsed)/TT_DAY);
		return [NSString stringWithFormat:NSLocalizedString(@"%d days ago", @""), days];
	}
	else {
		return [self formatDateTime];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortRelativeTime {
  NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);

  if (elapsed < TT_MINUTE) {
    return NSLocalizedString(@"<1m", @"Date format: less than one minute ago");

  } else if (elapsed < TT_HOUR) {
    int mins = (int)(elapsed / TT_MINUTE);
    return [NSString stringWithFormat:NSLocalizedString(@"%dm", @"Date format: 50m"), mins];

  } else if (elapsed < TT_DAY) {
    int hours = (int)((elapsed + TT_HOUR / 2) / TT_HOUR);
    return [NSString stringWithFormat:NSLocalizedString(@"%dh", @"Date format: 3h"), hours];

  } else if (elapsed < TT_WEEK) {
    int day = (int)((elapsed + TT_DAY / 2) / TT_DAY);
    return [NSString stringWithFormat:NSLocalizedString(@"%dd", @"Date format: 3d"), day];

  } else {
    return [self formatShortTime];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"MMMM d", @"Date format: July 27");
    formatter.locale = AKCurrentLocale();
  }

  NSCalendar* cal = [NSCalendar currentCalendar];
  NSDateComponents* day = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                               fromDate:self];

  if (day.day == today.day && day.month == today.month && day.year == today.year) {
    return NSLocalizedString(@"Today", @"");
  } else if (day.day == yesterday.day && day.month == yesterday.month
             && day.year == yesterday.year) {
    return NSLocalizedString(@"Yesterday", @"");
  } else {
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatMonth {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"MMMM", @"Date format: July");
    formatter.locale = AKCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatYear {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = NSLocalizedString(@"yyyy", @"Date format: 2009");
    formatter.locale = AKCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


@end
