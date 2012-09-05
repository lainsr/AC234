//
//  FolderListController.m
//  AC234
//
//  Created by Stéphane Rossé on 20.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ACStaticIcons.h"
#import "ACFolderListCell.h"
#import "ACFolderController.h"
#import "ACScrollViewController.h"
#import "ACAppDelegate.h"
#import "ACSlideViewController.h"

@implementation ACFolderController

static NSString *kCellIdentifier = @"MyIdentifier";

@synthesize hasChanged;
@synthesize folderPath, folderTildePath, folderList, parentSlideViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        lastCellForRow = -1;
        firstRowToThumbnail = -1;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setWantsFullScreenLayout:NO];
	self.tableView.separatorColor = [ACStaticIcons sepBackground];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.hasChanged = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if(lastSelectedRow >= 0 && lastSelectedRow < [self.folderList count]) {
		ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString *currentFile = [self.folderList objectAtIndex:lastSelectedRow];
		[appDelegate setLastViewed:currentFile];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)doUpdateOrientation {
    [self.tableView setNeedsLayout];
    for(UITableViewCell *visibleCell in [self.tableView visibleCells]) {
        [visibleCell setNeedsLayout];
    } 
}

- (void)didReceiveMemoryWarning {
	[thumbnailBuffer relax];
}

- (void)edit {
	BOOL editing = [self isEditing];
	[self setEditing:!editing];
	[self.tableView reloadData];
}

- (void)deselect {
	UITableView *tableView = (UITableView *)self.view;
	[tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:NO];
}

- (int)indexPathForSelectedRow {
	return lastSelectedRow;
}

- (void)startThumbnailAt:(int)row {
	firstRowToThumbnail = row;
}

- (void)selectFile:(NSString *)file {
    int indexToSelect = [folderList indexOfObject:file];
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
	[thumbnailBuffer removeAllObjects];
	
	lastCellForRow = 0;
	self.folderPath = folder;
	self.folderTildePath = [folder stringByAbbreviatingWithTildeInPath];
	self.folderList = filePaths;
	self.parentSlideViewController = slider;
	[self.tableView reloadData];
}

-(NSString*)currentVisibleFile {
    NSArray *visiblePath = [[self tableView] indexPathsForVisibleRows];
    if([visiblePath count] > 0) {
        int middle = [visiblePath count] / 2;
        NSIndexPath *middlePath = [visiblePath objectAtIndex:middle];
        if([folderList count] > middlePath.row) {
            return [folderList objectAtIndex:middlePath.row];
        } else if([folderList count] > 0) {
            return [folderList lastObject];
        }
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate
// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	lastSelectedRow = indexPath.row;
	NSString *selectedFolder = [self.folderList objectAtIndex:indexPath.row];
	
	//make some memory free
	[thumbnailBuffer relax];
	
	BOOL isDir;
	if ([[NSFileManager defaultManager] fileExistsAtPath:selectedFolder isDirectory:&isDir] && !isDir) {
		[(ACSlideViewController *)parentSlideViewController selectFile:selectedFolder];
	} else {
		[(ACSlideViewController *)parentSlideViewController selectFolder:selectedFolder];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource
// tell our table how many rows it will have, in our case the size of our menuList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.folderList count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ACFolderListCell *cell = (ACFolderListCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[ACFolderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	}
	
	int row = [indexPath row];
	NSString *filePath = [self.folderList objectAtIndex:row];
	NSString *filename = [filePath lastPathComponent];
	cell.filename = filename;
	[cell setRow:row];
	
	if(firstRowToThumbnail >= 0) {
		if(row < (firstRowToThumbnail - NUM_OF_THUMBNAILS)) {
			return cell;
		}
		firstRowToThumbnail = -1;
	}
	
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
		[self fillThumbnailsBufferAt:[indexPath row] waitUntilFilled:NO];
	}
	
	if([cell thumbnail] != NULL) {
		[cell setThumbnail:NULL];
	}
	if(thumbnail == NULL) {
		NSLog(@"Null thumbnail %@",filename);
	} else {
		[cell setThumbnail:thumbnail];
	}
	
	[thumbnailBuffer removeObjectForKey:filename];
	
	lastCellForRow = row;
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		NSString *filePath = [self.folderList objectAtIndex:indexPath.row];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		BOOL ok = [fileManager removeItemAtPath:filePath error:nil];
		if(ok) {
			[self.folderList removeObjectAtIndex:indexPath.row];
			self.hasChanged = YES;
		} else {
			NSMutableString *message = [NSMutableString stringWithCapacity:32];
			[message appendString:@"Cannot delete: "];
			[message appendString:[filePath lastPathComponent]];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
	[tableView reloadData];
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
		ACLoadThumbnailsOperation	*loadBatch = [[ACLoadThumbnailsOperation alloc] initWithPath:folderTildePath subSet:filenames size:NO];
		loadBatch.delegate	= self;		// set the delegate
		ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate thumbnailQueue] addOperation:loadBatch];
		if(wait) {
			[[appDelegate thumbnailQueue] waitUntilAllOperationsAreFinished];
		}
	}
}

@end
