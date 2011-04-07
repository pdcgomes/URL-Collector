//
//  Constants.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "Constants.h"

NSString *UserDefaults_ShorteningService			= @"shorteningService";
NSString *UserDefaults_URLCollectorDatabasePath		= @"URLCollectorDatabasePath";

NSString *URLCollectorDatabaseFileName				= @"URLCollectorDatabase.db";

// Notifications

NSString *const UCDroppedItemAtStatusBarNotification = @"UCDroppedItemAtStatusBarNotification";
NSString *const UCDroppedItemDraggingInfoKey = @"UCDroppedItemDraggingInfoKey";

// Functions
NSString *defaultURLCollectorGroupName(void)
{
	return NSLocalizedString(@"Inbox", @"");
}
