//
//  ACHThumbnailViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 10.10.12.
//
//
#import "ACScaler.h"
#import "ACAppDelegate.h"
#import "ACStaticIcons.h"
#import "ACHThumbnailViewController.h"
#import "ACThumbnailCollectionView.h"

@implementation ACHThumbnailViewController

@synthesize thumbnailCollectionViews, parentController = _parentController;
@synthesize folderList, selectedFile, currentDirPath, folderTildePath;

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.folderList count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int rowIndex = [indexPath indexAtPosition:0];
    NSString *filePath = [self.folderList objectAtIndex:rowIndex];
    [_parentController selectFile:filePath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ACThumbnailCollectionView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    int rowIndex = [indexPath indexAtPosition:0];
    NSString *filePath = [self.folderList objectAtIndex:rowIndex];
    NSString *filename = [filePath lastPathComponent];
    [cell setFilename:filename];
    
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate thumbnailQueue] addOperationWithBlock:^{
        
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
        NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [localContext setPersistentStoreCoordinator: [thumbnailStore persistentStoreCoordinator]];
        [localContext setUndoManager:NULL];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:thumbnailStore selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification object:localContext];
        
        UIImage *thumbnail = [ACScaler scale:localContext atFolderPath:self.folderTildePath image:filename size:YES];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(thumbnail == NULL) {
                NSLog(@"Null thumbnail %@",filename);
            } else if([cell.filename isEqualToString:filename]) {
                [cell addThumbnail:thumbnail];
                [cell setNeedsDisplay];
            }
        }];
    }];

    return cell;
}

@end
