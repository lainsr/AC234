//
//  ACAppDelegate.h
//  AC234
//
//  Created by Stéphane Rossé on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Folder.h"
#import "HTTPServer.h"
#import "ACCoreDataStore.h"
#import "ACPasswordDelegate.h"
#import "ACPasswordController.h"
#import "ACDeviceManager.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

@interface ACAppDelegate : UIResponder <UIApplicationDelegate,ACPasswordDelegate> {
	NSOperationQueue *thumbnailQueue;
    ACCoreDataStore *thumbnailStore;
    ACDeviceManager *deviceManager;
    
    HTTPServer *webdavServer;
    
	ACPasswordController *passwordController;
}

@property (nonatomic, strong, readonly) NSOperationQueue *thumbnailQueue;
@property (nonatomic, strong, readonly) ACCoreDataStore *thumbnailStore;
@property (nonatomic, strong, readonly) ACDeviceManager *deviceManager;

@property (nonatomic, strong, readonly) HTTPServer *webdavServer;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IBOutlet ACPasswordController *passwordController;


- (NSString *)getLastViewed:(NSString *)folder;
- (void)setLastViewed:(NSString *)file;
- (Folder *)getSavedFolder:(NSString *)folder;

- (NSString *)applicationCachesDirectory;
- (NSString *)applicationDocumentsDirectory;

//FTP server
- (NSString*)getAddress;

//WebDAV server
- (void)startWebDAVServer;
- (void)stopWebDAVServer;
- (void)toogleWebDAVServer;
- (void)toogleWebDAVServer:(BOOL)withAlert;

@end
