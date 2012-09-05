//
//  LoadThumbnailsOperation.m
//  AC234
//
//  Created by Stéphane Rossé on 08.05.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ACScaler.h"
#import "ACStaticIcons.h"
#import "ACLoadThumbnailsOperation.h"

#import "File.h"
#import "Image.h"
#import "ACCoreDataStore.h"
#import "ACAppDelegate.h"
#import <CoreGraphics/CoreGraphics.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ACLoadThumbnailsOperation (PrivateMethods)

- (void)scale:(NSManagedObjectContext *)localContext;

@end

@implementation ACLoadThumbnailsOperation

#define IMAGE 0
#define FOLDER 1
#define MOVIE 2
#define UNKOWN 3

@synthesize large, delegate, fullPaths, dirTildePath, imageNames;

-(id)initWithPaths:(NSArray *)paths size:(BOOL)largeThumbnails {
    self = [super init];
	if( (self) ) {
		fullPaths = paths;
        large = largeThumbnails;
        
	}
	return self;
}

-(id)initWithPath:(NSString *)tildePath subSet:(NSArray *)filenames size:(BOOL)largeThumbnails {
    self = [super init];
	if( (self) ) {
		dirTildePath = tildePath;
		imageNames = filenames;
        large = largeThumbnails;
	}
	return self;
}

-(void)main {
	if([self isCancelled]){
        return;
    }

    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
    NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [localContext setPersistentStoreCoordinator: [thumbnailStore persistentStoreCoordinator]];
    [localContext setUndoManager:NULL];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(mergeChanges:)
           name:NSManagedObjectContextDidSaveNotification object:localContext];

    [self scale:localContext];	
}

- (void)mergeChanges:(NSNotification *)notification {
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
    NSManagedObjectContext *mainContext = [thumbnailStore managedObjectContext];
    
    // Merge changes into the main context on the main thread
    [mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)
        withObject:notification waitUntilDone:NO];
}

-(void)scale:(NSManagedObjectContext *) localContext {
	BOOL loadByFullPath = (fullPaths != nil);
	int capacity = loadByFullPath ? [fullPaths count] : [imageNames count];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:localContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entity];
	[request setResultType:NSDictionaryResultType];
	[request setReturnsDistinctResults:YES];
    
    NSString *loadByAttr = loadByFullPath ? @"fullPath" : @"name";
	if(large) {
        [request setPropertiesToFetch:[NSArray arrayWithObjects:loadByAttr, @"type", @"thumbnailLargeImage", nil]];
    } else {
        [request setPropertiesToFetch:[NSArray arrayWithObjects:loadByAttr, @"type", @"thumbnailImage", nil]];
    }
    [request setFetchBatchSize:capacity];
	if(loadByFullPath) {
		[request setPredicate:[NSPredicate predicateWithFormat:@"(fullPath IN %@)", fullPaths]];
	} else {
		[request setPredicate:[NSPredicate predicateWithFormat:@"(name IN %@) AND (path == %@)", imageNames, dirTildePath]];
	}
	
	if([self isCancelled]) {
		return;
	}
	
	NSError *error = NULL;
	NSArray *results = [localContext executeFetchRequest:request error:&error];
	
	if([self isCancelled]) {
		return;
	}

	NSMutableDictionary *thumbnails = [NSMutableDictionary dictionaryWithCapacity:capacity];
	for(int i=[results count]; i-->0; ) {
        NSDictionary *resultDict =[results objectAtIndex:i];
		UIImage *thumbnail;
		NSString *key = loadByFullPath ? [resultDict objectForKey:@"fullPath"] : [resultDict objectForKey:@"name"];
		
        NSNumber *type = [resultDict objectForKey:@"type"];
        switch ([type intValue]) {
            case FOLDER: {
                if(large) {
                    thumbnail = [ACStaticIcons folderLargeIcon];
                } else {
                    thumbnail = [ACStaticIcons folderIcon];
                }
                break;
            }
            case UNKOWN: {
                thumbnail = [ACStaticIcons unkownIcon];
                break;
            } default: {
                if(large) {
                    thumbnail = [resultDict objectForKey:@"thumbnailLargeImage"];
                } else {
                    thumbnail = [resultDict objectForKey:@"thumbnailImage"];
                }
                
                if(thumbnail == nil) {
                    thumbnail = [ACStaticIcons unkownIcon];
                }
            }
        }
        
		[delegate thumbnailFinished:thumbnail forFile:key];
		[thumbnails setObject:thumbnail forKey:key];
	}
 	
	if([self isCancelled]) return;
	
	NSString *expandedPath = NULL;
	if([results count] != [imageNames count]) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		for(int i=[imageNames count]; i-->0; ) {
			if([self isCancelled]) {
				break;
			}
			
			NSString *file = loadByFullPath ? [fullPaths objectAtIndex:i] : [imageNames objectAtIndex:i];
			if([thumbnails valueForKey:file] == nil) {
				File *savedFile = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:localContext];
				if(loadByFullPath) {
					savedFile.name = [file lastPathComponent];
					savedFile.path = [[file stringByDeletingLastPathComponent] stringByAbbreviatingWithTildeInPath];
					savedFile.fullPath = file;
				} else {
					if(expandedPath == NULL) {
						expandedPath = [dirTildePath stringByExpandingTildeInPath];
					}
					savedFile.path = dirTildePath;
					savedFile.name = file;
					savedFile.fullPath = [expandedPath stringByAppendingPathComponent:file];
				}

				BOOL isDir;
				if ([fileManager fileExistsAtPath:[savedFile fullPath] isDirectory:&isDir] && !isDir) {     
                    UIImage *thumbnail;
                    [ACScaler extractThumbnailFrom:[savedFile fullPath] toFile:savedFile];
                    if(large) {
                        thumbnail = [savedFile thumbnailLargeImage];
                    } else {
                        thumbnail = [savedFile thumbnailImage];
                    }
                    if(thumbnail != nil) {
                        [delegate thumbnailFinished:thumbnail forFile:file];
                    } else {
                        [delegate thumbnailFinished:[ACStaticIcons unkownIcon] forFile:file];
                    }
				} else if (isDir) {
					savedFile.type = [NSNumber numberWithInt:FOLDER];
					if(large) {
                        [delegate thumbnailFinished:[ACStaticIcons folderLargeIcon] forFile:file];
                    } else {
                        [delegate thumbnailFinished:[ACStaticIcons folderIcon] forFile:file];
                    }
                } else {
					[delegate thumbnailFinished:[ACStaticIcons unkownIcon] forFile:file];
				}
				
				if(![[savedFile managedObjectContext] save:&error]) {
					NSLog(@"Cannot save thumbnail %@, %@", error, [error userInfo]);
				}
			}
		}
	}
}

@end
