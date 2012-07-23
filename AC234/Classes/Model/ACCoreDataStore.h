//
//  ACMementoStore.h
//  AC234
//
//  Created by Stéphane Rossé on 23.01.12.
//  Copyright (c) 2012 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACCoreDataStore : NSObject {
    
    NSString *databaseFilename;

}

@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (id)initWithFile:(NSString*)name;
- (NSString *)applicationCachesDirectory;
- (void)deleteStore;
- (void)stopStore;

@end
