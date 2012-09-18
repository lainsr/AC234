//
//  ACUpdateThumbnailsOperation.m
//  AC234
//
//  Created by Stéphane Rossé on 06.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ACScaler.h"
#import "ACUpdateInfos.h"
#import "ACAppDelegate.h"
#import "ACUpdateThumbnailsOperation.h"


@implementation ACUpdateThumbnailsOperation

@synthesize delegate, reset;

-(void)main {
	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (reset) {
		//dangerous
        //[appDelegate.thumbnailStore deleteStore];
	}

	NSString *documentDir = [appDelegate applicationDocumentsDirectory];
	NSMutableArray *collector = [NSMutableArray arrayWithCapacity:2000];
	[self collectThumbnailsPathIn:collector at:documentDir];
	
	if([self isCancelled]) {
		return;
	}
    
    ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [localContext setPersistentStoreCoordinator: [thumbnailStore persistentStoreCoordinator]];
    [localContext setUndoManager:NULL];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(mergeChanges:)
               name:NSManagedObjectContextDidSaveNotification object:localContext];
	
	[self updateThumbnails:collector withContext:localContext];
	[self.delegate operationFinished:self];
}

- (void)mergeChanges:(NSNotification *)notification {
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
    NSManagedObjectContext *mainContext = [thumbnailStore managedObjectContext];
    
    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
                                  withObject:notification waitUntilDone:NO];
}

- (void)collectThumbnailsPathIn:(NSMutableArray *)collector at:(NSString *)dir {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:dir];
	NSString *file;
	while ((file = [dirEnum nextObject])) {
		NSString *filename = [file lastPathComponent];
		if([filename hasPrefix:@"."] || [filename hasPrefix:@"AC234.sqlite"] || [filename hasPrefix:@"tmp_transmit_time_offset"]) {
			//ignore them
		} else {
			NSString *subPath = [dir stringByAppendingPathComponent:file];
			[collector addObject:subPath];
        }
	}
}

- (void)updateThumbnails:(NSMutableArray *)collector withContext:(NSManagedObjectContext *)localContext {
	int count = 0;
	for(NSString *imagePath in collector) {
		[ACScaler createThumbnail:imagePath withContext:localContext];

		float progress = (((float)count) / ((float)[collector count]));
		ACUpdateInfos *infos = [[ACUpdateInfos alloc] initWithProgress:progress];
		[infos setPath:imagePath];
		[infos setCurrentPosition:count];
		[infos setNumberOfThumbnails:[collector count]];
		[delegate updateThumbnailsProgress:infos];

		++count;
		if([self isCancelled]) {
			break;
		}
	}
}

@end
