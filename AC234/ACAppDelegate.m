//
//  ACAppDelegate.m
//  AC234
//
//  Created by Stéphane Rossé on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACAppDelegate.h"
#import "ACGlobalInfos.h"


static int MAX_OPERATION_QUEUE_SIZE = 1;

@implementation ACAppDelegate

@synthesize window = _window;
@synthesize passwordController =_passwordController;
@synthesize thumbnailQueue = _thumbnailQueue;
@synthesize thumbnailStore = _thumbnailStore;
@synthesize deviceManager = _deviceManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    thumbnailQueue = [[NSOperationQueue alloc]init];
	[thumbnailQueue setMaxConcurrentOperationCount:MAX_OPERATION_QUEUE_SIZE];
    
    _thumbnailStore = [[ACCoreDataStore alloc] initWithFile:@"AC234.sqlite"];
    [_thumbnailStore managedObjectContext];
    
    //instance devices manager
    _deviceManager = [[ACDeviceManager alloc]init];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if([[ACGlobalInfos sharedInstance] isPasswordActivated]) {
        _passwordController = [[ACPasswordController alloc] initWithNibName:@"ACPasswordView" bundle:nil];
        [_passwordController setPasswordDelegate:self];
        [_window.rootViewController presentModalViewController:_passwordController animated:NO];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(_passwordController == NULL && [[ACGlobalInfos sharedInstance] isPasswordActivated]) {
        _passwordController = [[ACPasswordController alloc] initWithNibName:@"ACPasswordView" bundle:nil];
        [_passwordController setPasswordDelegate:self];
        [_window.rootViewController presentModalViewController:_passwordController animated:NO];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate.
    // Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark ACPasswordDelegate
-(BOOL)passwordSet:(NSString *)password {
	if([[ACGlobalInfos sharedInstance] checkPassword:password]) {
        [_window.rootViewController dismissModalViewControllerAnimated:NO];
        [_passwordController setPasswordDelegate:NULL];
        _passwordController = NULL;
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark Position preferences
- (NSString *)getLastViewed:(NSString *)folder {
	Folder *savedFolder = [self getSavedFolder:folder];
	if(savedFolder.lastViewed == NULL) {
		return NULL;
	} else {
		NSString *documents = [self applicationDocumentsDirectory];
		return [documents stringByAppendingString:savedFolder.lastViewed];
	}
}

- (void)setLastViewed:(NSString *)file {
	if (file == nil) {
		return;//nothing selected, don't change the last selected file
	}
    
	NSString *documents = [self applicationDocumentsDirectory];
	NSString *fileKey = [file substringFromIndex:[documents length]];
	NSString *folder = [file stringByDeletingLastPathComponent];
    
	Folder *savedFolder = [self getSavedFolder:folder];
	savedFolder.lastViewed = fileKey;
}

- (Folder *)getSavedFolder:(NSString *)folder {
	NSString *documents = [self applicationDocumentsDirectory];
	NSString *folderKey = [folder substringFromIndex:[documents length]];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:[self.thumbnailStore managedObjectContext]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"path == %@", folderKey]];
	
    NSError *error;
    NSArray *result = [[self.thumbnailStore managedObjectContext] executeFetchRequest:request error:&error];
	
    Folder *savedFolder;
    if([result count] == 0) {
        savedFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:[self.thumbnailStore managedObjectContext]];
        savedFolder.path = folderKey;
        if(![[self.thumbnailStore managedObjectContext] save:&error]) {
            NSLog(@"Cannot commit management context");
        }
    } else {
        savedFolder = [result lastObject];
    }
    
	return savedFolder;
}

#pragma mark -
#pragma mark Thumnbnails
- (NSOperationQueue *) thumbnailQueue {
	return thumbnailQueue;
}

- (ACCoreDataStore*)thumbnailStore {
    return _thumbnailStore;
}

- (ACDeviceManager*)deviceManager {
    return _deviceManager;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)applicationCachesDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end
