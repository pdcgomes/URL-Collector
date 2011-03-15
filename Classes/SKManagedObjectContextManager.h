//
//  ManagedObjectModelManager.h
//  SAPO_Cinema_iPhone
//
//  Created by Pedro Gomes on 11/5/09.
//  Copyright 2009 SAPO. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SKManagedObjectContextManager : NSObject 
{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *defaultManagedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *defaultManagedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (SKManagedObjectContextManager *)sharedInstance;

- (NSManagedObjectContext *)newManagedObjectContext;

- (NSString *)applicationDocumentsDirectory;

- (BOOL)save;
- (BOOL)saveInContext:(NSManagedObjectContext *)context error:(NSError **)error;

- (void)deleteObjects:(NSArray *)managedObjects;
- (void)deleteObjects:(NSArray *)managedObjects context:(NSManagedObjectContext *)context;

- (id)insertNewEntityForName:(NSString *)entityName;
- (id)insertNewEntityForName:(NSString *)entityName context:(NSManagedObjectContext *)context;

extern NSString *SKManagedObjectCreatedAtKey;
extern NSString *SKManagedObjectUpdatedAtKey;

@end
