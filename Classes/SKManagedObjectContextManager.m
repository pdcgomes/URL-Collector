//
//  ManagedObjectModelManager.m
//  SAPO_Cinema_iPhone
//
//  Created by Pedro Gomes on 11/5/09.
//  Copyright 2009 SAPO. All rights reserved.
//

#import "SKManagedObjectContextManager.h"
#import "SKObjectSingleton.h"

NSString *SKManagedObjectCreatedAtKey = @"SKManagedObjectCreateAtTimestamp";
NSString *SKManagedObjectUpdatedAtKey = @"SKManagedObjectUpdatedAtTimestamp";

@interface SKManagedObjectContextManager()

- (void)managedObjectContextWillSaveNotification:(NSNotification *)notification;

@end

@implementation SKManagedObjectContextManager

#pragma mark -
#pragma mark Singleton
#pragma mark -

SK_OBJECT_SINGLETON_BOILERPLATE(SKManagedObjectContextManager, sharedInstance);

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc 
{
	SKSafeRelease(defaultManagedObjectContext);
	SKSafeRelease(managedObjectModel);
	SKSafeRelease(persistentStoreCoordinator);
	
	[super dealloc];
}

- (id)init
{
	if((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(managedObjectContextWillSaveNotification:) 
													 name:NSManagedObjectContextWillSaveNotification 
												   object:nil];
	}
	return self;
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *)newManagedObjectContext
{
	NSManagedObjectContext *context = nil;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}

- (NSManagedObjectContext *)defaultManagedObjectContext 
{
    if (defaultManagedObjectContext != nil) {
        return defaultManagedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if(coordinator != nil) {
        defaultManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [defaultManagedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return defaultManagedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeURL = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"URLCollector.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		
		ERROR(@"PersistentStoreCoordinator was unable to add the persistent store with URL: %@, this is probably due to a new data model version.", storeURL);
		ERROR(@"Will now attempt removal of old data model and creation of the new updated version.");

		if(![[NSFileManager defaultManager] removeItemAtPath:[storeURL path] error:&error]) {
//		if(![persistentStoreCoordinator removePersistentStore:[persistentStoreCoordinator persistentStoreForURL:storeUrl] error:&error]) {
			FATAL(@"Unable to remove old data model version. Error info: %@, %@", error, [error userInfo]);
			FATAL(@"Aborting...");
			abort();
		}
		
		if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
			FATAL(@"Unable to re-create the data model. Error info: %@, %@", error, [error userInfo]);
			abort();
		}
		INFO(@"Data model has been successfully re-created.");
    }    
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents directory

- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Public Methods

- (id)insertNewEntityForName:(NSString *)entityName
{
	return [self insertNewEntityForName:entityName context:self.defaultManagedObjectContext];
}

- (id)insertNewEntityForName:(NSString *)entityName context:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
}

- (BOOL)save
{
	NSError *error = nil;
	return [self.defaultManagedObjectContext save:&error];
}

- (BOOL)saveInContext:(NSManagedObjectContext *)context error:(NSError **)error
{
	return [context save:error];
}

- (void)deleteObjects:(NSArray *)managedObjects
{
	[self deleteObjects:managedObjects context:self.defaultManagedObjectContext];
}

- (void)deleteObjects:(NSArray *)managedObjects context:(NSManagedObjectContext *)context
{
	for(NSManagedObject *managedObject in managedObjects) {
		[context deleteObject:managedObject];
	}
}

#pragma mark -
#pragma mark Private Methods

- (void)managedObjectContextWillSaveNotification:(NSNotification *)notification
{
	NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
	
	// The following try/catch blocks are here for safety, in the future we will ensure 
	// all ManagedObjects respond to createdAt/updatedAt 
	@try {
		[updatedObjects setValue:[NSDate date] forKey:@"updatedAt"];
	}
	@catch (NSException *e) {
		for(NSManagedObject *managedObject in updatedObjects) {
			if([managedObject respondsToSelector:@selector(setUpdatedAt:)]) {
				[managedObject performSelector:@selector(setUpdatedAt:) withObject:[NSDate date]];
			}
		}
	}
	
	NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
	@try {
		[insertedObjects setValue:[NSDate date] forKey:@"createdAt"];
		[insertedObjects setValue:[NSDate date] forKey:@"updatedAt"];
	}
	@catch (NSException *e) {
		for(NSManagedObject *managedObject in insertedObjects) {
			if([managedObject respondsToSelector:@selector(setCreatedAt:)]) {
				[managedObject performSelector:@selector(setCreatedAt:) withObject:[NSDate date]];
			}
			if([managedObject respondsToSelector:@selector(setUpdatedAt:)]) {
				[managedObject performSelector:@selector(setUpdatedAt:) withObject:[NSDate date]];
			}
		}
	}
}

@end
