//
//  Constants.h
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/9/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *UserDefaults_ShorteningService;
extern NSString *UserDefaults_URLCollectorDatabasePath;
extern NSString *UserDefaults_iCloudSyncEnabled;
extern NSString *UserDefaults_PreserveSyncedChanges;

NSString *URLCollectorDatabaseFileName;

// Notifications
extern NSString *const UCDroppedItemAtStatusBarNotification;
extern NSString *const UCDroppedItemDraggingInfoKey;
// Functions
NSString *defaultURLCollectorGroupName(void);