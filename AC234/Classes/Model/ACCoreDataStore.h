//
//  ACCoreDataStore.h
//  AC234
//
//  Created by Stéphane Rossé on 23.01.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACCoreDataStore : NSObject {
    
    NSString *databaseFilename;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
}

@property (nonatomic, strong) NSString *databaseFilename;

@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (id)initWithFile:(NSString*)name;
- (NSString *)applicationCachesDirectory;

- (void)mergeChanges:(NSNotification *)notification;
- (void)stopStore;

@end
