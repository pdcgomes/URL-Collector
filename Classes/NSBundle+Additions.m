//
//  NSBundle+Additions.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/14/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "NSBundle+Additions.h"

@implementation NSBundle(PathAdditions)

- (NSString *)applicationSupportPath
{
	NSArray			*dirs = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString		*appSupportFolderPath = [dirs objectAtIndex:0];
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	BOOL			isDirectory = NO;
	
	if(![fileManager fileExistsAtPath:appSupportFolderPath]) {
		[fileManager createDirectoryAtPath:appSupportFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	NSString *appExecutableName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleExecutableKey];
	NSString *appFolderPath = [appSupportFolderPath stringByAppendingPathComponent:appExecutableName];
	
	if(![fileManager fileExistsAtPath:appFolderPath isDirectory:&isDirectory]) {
		[fileManager createDirectoryAtPath:appFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	else if(!isDirectory) {
		[fileManager removeItemAtPath:appFolderPath error:NULL];
		[fileManager createDirectoryAtPath:appFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return appFolderPath;
}


- (NSString *)applicationCachesPath
{
	NSArray			*dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString		*cachesFolderPath = [dirs objectAtIndex:0];
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:cachesFolderPath]) {
		[fileManager createDirectoryAtPath:cachesFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	NSString *appExecutableName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleExecutableKey];
	NSString *appFolderPath = [cachesFolderPath stringByAppendingPathComponent:appExecutableName];
	
	if(![fileManager fileExistsAtPath:appFolderPath]) {
		[fileManager createDirectoryAtPath:appFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return appFolderPath;
}

@end
