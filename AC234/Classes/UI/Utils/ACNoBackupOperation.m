//
//  ACNoBackupOperation.m
//  AC234
//
//  Prevents backup of the images
//
//  Created by Stéphane Rossé on 02.10.13.
//
//

#import "ACNoBackupOperation.h"
#import "ACAppDelegate.h"

@implementation ACNoBackupOperation

-(void)main {
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *documentDir = [appDelegate applicationDocumentsDirectory];
    NSURL *documentUrl = [NSURL fileURLWithPath:documentDir isDirectory:YES];
    NSArray *keys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, NSURLIsExcludedFromBackupKey, nil];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:documentUrl
                                         includingPropertiesForKeys:keys
                                         options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants |  NSDirectoryEnumerationSkipsHiddenFiles)
                                         errorHandler:nil];
    
	for (NSURL *url in enumerator) {
        NSNumber *isExcluded = nil;
        [url getResourceValue:&isExcluded forKey:NSURLIsExcludedFromBackupKey error:NULL];
        if (![isExcluded boolValue]) {
            [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:NULL];
        }
    }
}

@end
