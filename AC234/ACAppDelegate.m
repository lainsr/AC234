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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    thumbnailQueue = [[NSOperationQueue alloc]init];
	[thumbnailQueue setMaxConcurrentOperationCount:MAX_OPERATION_QUEUE_SIZE];
    
    _thumbnailStore = [[ACCoreDataStore alloc] initWithFile:@"AC234.sqlite"];
    [_thumbnailStore managedObjectContext];
    
    if(YES || [[ACGlobalInfos sharedInstance] isPasswordActivated]) {
        //_passwordController = [[ACPasswordController alloc] initWithNibName:@"ACPasswordView" bundle:nil];
        //[_passwordController setPasswordDelegate:self];
        //[_window.rootViewController presentModalViewController:_passwordController animated:NO];

	}
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _passwordController = [[ACPasswordController alloc] initWithNibName:@"ACPasswordView" bundle:nil];
    [_passwordController setPasswordDelegate:self];
    [_window.rootViewController presentModalViewController:_passwordController animated:NO];
    
    NSLog(@"applicationDidEnterBackground");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    //UIViewController *rootController = [UIApplication sharedApplication].delegate.window.rootViewController;
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //UIStoryboard *storyboard = rootController.storyboard;
    
    //UIViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"AskPasswordVC"];
    //[rootController performSegueWithIdentifier:@"AskPassword" sender:self];
    //[rootController presentModalViewController:loginController animated:YES];
    
    //_passwordController = [[ACPasswordController alloc] initWithNibName:@"ACPasswordView" bundle:nil];
    //[_passwordController setPasswordDelegate:self];
    //[_window.rootViewController presentModalViewController:_passwordController animated:NO];
    
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark ACPasswordDelegate
-(BOOL)passwordSet:(NSString *)password {
	if([[ACGlobalInfos sharedInstance] checkPassword:password]) {
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
