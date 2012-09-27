//
//  ACCoreDataStore.m
//  AC234
//
//  Created by Stéphane Rossé on 23.01.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import "ACCoreDataStore.h"

@implementation ACCoreDataStore

@synthesize databaseFilename;
@synthesize managedObjectModel = _managedObjectModel,
    managedObjectContext = _managedObjectContext,
    persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)initWithFile:(NSString*)name {
    self = [super init];
	if (self) {
        self.databaseFilename = name;
	}
	return self;
}

- (void)stopStore {
    NSError *error;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

/**
 * Perform the merge on the main thread
**/
- (void)mergeChanges:(NSNotification *)notification {
    if(_managedObjectContext == NULL) return;
    // Merge changes into the main context on the main thread
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification waitUntilDone:NO];
}

- (NSManagedObjectContext *) managedObjectContext {
	if (_managedObjectContext != nil) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
        [_managedObjectContext setUndoManager:NULL];
	}
	return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	return _managedObjectModel;
}

- (void)deleteStore {
    NSString *sqlPath = [[self applicationCachesDirectory] stringByAppendingPathComponent:[self databaseFilename]];
	[[NSFileManager defaultManager] removeItemAtPath:sqlPath error:nil];
	_persistentStoreCoordinator = nil;
	[self persistentStoreCoordinator];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}
	
	NSString *sqlPath = [[self applicationCachesDirectory] stringByAppendingPathComponent:[self databaseFilename]];
	NSURL *storeUrl = [NSURL fileURLWithPath: sqlPath];
	
	NSError *error;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[[NSFileManager defaultManager] removeItemAtPath:sqlPath error:nil];
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
			NSLog(@"Completly unresolved error %@, %@", error, [error userInfo]);
		} 
	}    
	
	return _persistentStoreCoordinator;
}

- (NSString *)applicationCachesDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end
