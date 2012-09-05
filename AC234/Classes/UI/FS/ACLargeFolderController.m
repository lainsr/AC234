//
//  Class.m
//  AC234
//
//  Created by Stéphane Rossé on 02.04.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import "ACLargeFolderController.h"
#import "ACSlideViewController.h"
#import "ACAppDelegate.h"
#import "ACLargeThumbnailListCell.h"

@implementation ACLargeFolderController

static NSString *kCellIdentifier = @"LargeIconsIdentifier";

@synthesize folderPath, folderTildePath, folderList;
@synthesize parentSlideViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        lastCellForRow = -1;
        firstRowToThumbnail = -1;
        numOfThumbnailPerLine = 3;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setWantsFullScreenLayout:NO];
}

- (void)didReceiveMemoryWarning {
    [thumbnailBuffer relax];
}

#pragma mark - View lifecycle
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)doUpdateOrientation {
    NSIndexPath *indexPath = NULL;
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    if(visiblePaths != nil && [visiblePaths count] > 0) {
        indexPath = [visiblePaths objectAtIndex:0];
    }
 
    double indexToSelect = -1.0;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        if(numOfThumbnailPerLine != 4) {
            if(indexPath != nil) {
                indexToSelect = floor(((indexPath.row * 3.0) / 4.0) + 0.5);
            }
            numOfThumbnailPerLine = 4;
        }
    } else if (numOfThumbnailPerLine != 3){
        if(indexPath != nil) {
            indexToSelect = floor(((indexPath.row * 4.0) / 3.0) + 0.5);
        }
        numOfThumbnailPerLine = 3;
    }

    [self.tableView reloadData];
    if(indexToSelect >= 0.0) {
        NSUInteger indexArr[] = {0,indexToSelect};
        NSIndexPath *newIndexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
        [self.tableView selectRowAtIndexPath:(NSIndexPath *)newIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

-(NSString*)currentVisibleFile{
    NSArray *visiblePath = [[self tableView] indexPathsForVisibleRows];
    if([visiblePath count] > 0) {
        int middle = [visiblePath count] / 2;
        NSIndexPath *middlePath = [visiblePath objectAtIndex:middle];
        int fileIndex = middlePath.row * numOfThumbnailPerLine;
        if([folderList count] > fileIndex) {
            return [folderList objectAtIndex:fileIndex];
        } else if([folderList count] > 0) {
            return [folderList lastObject];
        }
    }
    return nil;
}

- (void)selectFile:(NSString *)file {
    int index = [folderList indexOfObject:file];
    int indexToSelect = index / numOfThumbnailPerLine;
    if(indexToSelect >= 0) {
		NSUInteger indexArr[] = {0,indexToSelect};
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
        
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        if(visiblePaths != nil) {
            for(int i=[visiblePaths count]; i-->0; ) {
                NSIndexPath *visiblePath = [visiblePaths objectAtIndex:i];
                if([visiblePath compare:indexPath] == NSOrderedSame) {
                    return;
                }
            }
        }

        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)loadFolder:(NSString *)folder withImages:(NSMutableArray *)filePaths fromSlideView:(UIViewController *)slider {
	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate thumbnailQueue] cancelAllOperations];
	[self.thumbnailBuffer removeAllObjects];
    [self updateOrientation];
	
	lastCellForRow = 0;
	self.folderPath = folder;
	self.folderTildePath = [folder stringByAbbreviatingWithTildeInPath];
	self.folderList = filePaths;
	self.parentSlideViewController = slider;
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath iconAt:(NSUInteger)index {
    lastSelectedRow = indexPath.row;
    int fileIndex = indexPath.row * numOfThumbnailPerLine + index;
    if(fileIndex >= 0 && fileIndex < [self.folderList count]) {
        NSString *selectedFolder = [self.folderList objectAtIndex:fileIndex];
    
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:selectedFolder isDirectory:&isDir] && !isDir) {
            [(ACSlideViewController *)parentSlideViewController selectFile:selectedFolder];
        } else {
            [(ACSlideViewController *)parentSlideViewController selectFolder:selectedFolder];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    lastSelectedRow = indexPath.row;
    //int selectedFile = lastSelectedRow 
    
    
	NSString *selectedFolder = [self.folderList objectAtIndex:indexPath.row];

	BOOL isDir;
	if ([[NSFileManager defaultManager] fileExistsAtPath:selectedFolder isDirectory:&isDir] && !isDir) {
		[(ACSlideViewController *)parentSlideViewController selectFile:selectedFolder];
	} else {
		[(ACSlideViewController *)parentSlideViewController selectFolder:selectedFolder];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104.0f;
}

#pragma mark -
#pragma mark UITableViewDataSource
// tell our table how many rows it will have, in our case the size of our menuList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numOfRow = [self.folderList count] / numOfThumbnailPerLine;
    int rest = [self.folderList count] % numOfThumbnailPerLine;
    if(rest > 0) {
        numOfRow++;
    }
    return numOfRow;
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ACLargeThumbnailListCell *cell = (ACLargeThumbnailListCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[ACLargeThumbnailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	}
	
	int row = [indexPath row];
	if(firstRowToThumbnail >= 0) {
		if(row < (firstRowToThumbnail - (NUM_OF_THUMBNAILS / 3))) {
			return cell;
		}
		firstRowToThumbnail = -1;
	}
    
    int thumbnailPosition = row * numOfThumbnailPerLine;
    [cell.thumbnails removeAllObjects];
    for (int i=0; i<numOfThumbnailPerLine; i++) {
        int currentThumbnail = thumbnailPosition + i;
        if(currentThumbnail < [self.folderList count]) {
            NSString *filePath = [self.folderList objectAtIndex:currentThumbnail];
            NSString *filename = [filePath lastPathComponent];
            [self loadThumbnailInCell:cell atRow:currentThumbnail forImage:filename];
        }
    }
    [cell setRow:row];
	lastCellForRow = row;
	return cell;
}

- (void)loadThumbnailInCell:(ACLargeThumbnailListCell *)cell atRow:(int)row forImage:(NSString *)filename {
	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIImage *thumbnail = [thumbnailBuffer objectForKey:filename];
	if(thumbnail == nil) {
		//check if the next
		if([[[appDelegate thumbnailQueue]operations]count] > PANIC_OPERATION_QUEUE_SIZE) {
			if ([thumbnailBuffer reserved:filename]) {
				int count = 0;
				while (thumbnail == nil) {
					struct timespec ts;
					ts.tv_sec = 0;
					ts.tv_nsec = 10000000;
					nanosleep(&ts, NULL);
					thumbnail = [thumbnailBuffer objectForKey:filename];
					if(count++ > 20) {
						break;
					}
				}
			}
			
			if(thumbnail == nil) {
				[[appDelegate thumbnailQueue] waitUntilAllOperationsAreFinished];
				thumbnail = [thumbnailBuffer objectForKey:filename];
				if(thumbnail == nil) {
					//miss the right thumbnails
					[thumbnailBuffer removeAllObjects];
					[self fillThumbnailsBufferAt:row waitUntilFilled:YES];
				}
			}
		} else {
			[self fillThumbnailsBufferAt:row waitUntilFilled:YES];
		}
		thumbnail = [thumbnailBuffer objectForKey:filename];
	} else if ([thumbnailBuffer count] < PANIC_SIZE && [[[appDelegate thumbnailQueue]operations]count] == 0) {
		[self fillThumbnailsBufferAt:row waitUntilFilled:NO];
	}

	if(thumbnail == NULL) {
		NSLog(@"Null thumbnail %@",filename);
	} else {
		[cell.thumbnails addObject:thumbnail];
	}
	
	[thumbnailBuffer removeObjectForKey:filename];
}

#pragma mark -
#pragma mark Thumbnails
- (void)fillThumbnailsBufferAt:(int)row waitUntilFilled:(BOOL)wait {
    
	NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:DEFAULT_CACHE_SIZE];
	@synchronized(thumbnailBuffer) {
		BOOL cancel = NO;
        
		if(lastCellForRow <= row) {
			int nextStop = row + DEFAULT_CACHE_SIZE;
            
			for(int i=row; i<nextStop && i<[self.folderList count];i++) {
				NSString *path = [self.folderList objectAtIndex:i];
				NSString *filename = [path lastPathComponent];
				if (![thumbnailBuffer reserved:filename]) {
					[thumbnailBuffer reservationForKey:filename];
					[filenames addObject:filename];
					if(!wait && i - row > 20) {
						cancel = YES;
						break;
					}
				}
			}
		} else {
			int nextStop = row - DEFAULT_CACHE_SIZE;
            
			for(int i=row; i>=nextStop && i>=0; i--) {
				NSString *path = [self.folderList objectAtIndex:i];
				NSString *filename = [path lastPathComponent];
				if(![thumbnailBuffer reserved:filename]) {
					[thumbnailBuffer reservationForKey:filename];
					[filenames addObject:filename];
					if(!wait && row - i > 20) {
						cancel = YES;
						break;
					}
				}
			}
		}
		
		if(cancel) {
			for(int i=[filenames count]; i-->0; ) {
				[thumbnailBuffer cancelReservationForKey:[filenames objectAtIndex:i]];
			}
			return;
		}
	}
	
	if([filenames count] > 0) {
		ACLoadThumbnailsOperation *loadBatch = [[ACLoadThumbnailsOperation alloc] initWithPath:folderTildePath subSet:filenames size:YES];
		loadBatch.delegate = self;// set the delegate
		ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate thumbnailQueue] addOperation:loadBatch];
		if(wait) {
			[[appDelegate thumbnailQueue] waitUntilAllOperationsAreFinished];
		}
	}
}

@end
