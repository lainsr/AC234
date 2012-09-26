//
//  ACFileListController.m
//  AC234
//
//  Created by Stéphane Rossé on 02.09.12.
//
//
#import "ACGlobalInfos.h"
#import "ACAppDelegate.h"
#import "ACFolderListCell.h"
#import "ACFileListController.h"
#import "ACScrollViewController.h"
#import "ACSearchViewController.h"
#import "ACLargeThumbnailListCell.h"
#import "ACThumbnailCell.h"


@interface ACFileListController (Private)

-(NSString*)findUniqueName;
-(void)generateName:(int)number andAppendTo:(NSMutableString *)string;
-(void)fillThumbnailsBufferAt:(int)row size:(BOOL)large waitUntilFilled:(BOOL)wait;
-(void)loadThumbnailInCell:(UITableViewCell<ACThumbnailCell>*)cell atRow:(int)row forImage:(NSString *)filename atSize:(BOOL)large;

@end

@implementation ACFileListController

static NSString *kCellIdentifier = @"CustomSingleIconCell";
static NSString *kLargeCellIdentifier = @"CustomMultiIconCell";


//headers variables
@synthesize flipIndicatorButton, organizeButton, addButton, cancelEditButton;
@synthesize rightButtonBackup, backButtonBackup, flipToolbar;
@synthesize folderList, folderTildePath, folderPath, hasChanged;
@synthesize subController;
@synthesize lastSelectedRow, lastCellForRow, firstRowToThumbnail, numOfThumbnailPerCell, cellStyle;

#pragma mark -
#pragma mark View life cycle
- (void)viewDidLoad {
	[super viewDidLoad];
    [self setCellStyle:kList];
    [self setNumOfThumbnailPerCell:3];
	[self setWantsFullScreenLayout:NO];
    
    if(self.folderList == NULL) {
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setFolderTildePath:[appDelegate applicationDocumentsDirectory]];
        [self setTitle:@"Home"];
        [self loadFolder:[self folderTildePath]]; 
    }
    
    self.flipIndicatorButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,31,31)];
    [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"ListWithBack.png"] forState:UIControlStateNormal];
    [self.flipIndicatorButton addTarget:self action:@selector(flipCurrentView) forControlEvents:(UIControlEventTouchDown)];
    [self.flipIndicatorButton setOpaque:YES];
    [self.flipIndicatorButton setAlpha:1.0];
    
	UIBarButtonItem *sButton=[[UIBarButtonItem alloc] initWithCustomView:flipIndicatorButton];
    
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
    [buttons addObject:sButton];
    [buttons addObject:self.organizeButton];
    
    [self.navigationItem setRightBarButtonItems:buttons animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *file = (NSString *)sender;
    UIViewController *destinationController = [segue destinationViewController];
    if([destinationController isKindOfClass: [ACScrollViewController class]]) {
        ACScrollViewController *scrollController = (ACScrollViewController *)destinationController;
        if ([self hasChanged]) {
            [scrollController setFile:file inFolder:folderPath withContent:folderList];
            [self setHasChanged:NO];//consume the changes and reload the scrollview
        } else if ([folderPath isEqualToString:[scrollController currentDirectory]]) {
            [scrollController selectFile:file];
        } else {
            [scrollController setFile:file inFolder:folderPath withContent:folderList];
        }
        
        //hide bars and set them as transparent
        [self.navigationController setNavigationBarHidden:YES animated:NO];
		[[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
		[[self.navigationController toolbar] setBarStyle:UIBarStyleBlackTranslucent];
		[self.navigationController setDelegate:self];
		
        UIApplication *sharedApp = [UIApplication sharedApplication];
        [sharedApp setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		[sharedApp setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([self cellStyle] != kLarge) {
        return;
    }
    
    NSIndexPath *indexPath = NULL;
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    if(visiblePaths != nil && [visiblePaths count] > 0) {
        indexPath = [visiblePaths objectAtIndex:0];
    }
    
    double indexToSelect = -1.0;
    int thumbnailsPerLandscapeCell = [[ACGlobalInfos sharedInstance] numberOfThumbnailPerLandscapeCell];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        if([self numOfThumbnailPerCell] != thumbnailsPerLandscapeCell) {
            if(indexPath != nil) {
                indexToSelect = floor(((indexPath.row * 3.0) / (float)thumbnailsPerLandscapeCell) + 0.5);
            }
            [self setNumOfThumbnailPerCell:thumbnailsPerLandscapeCell];
        }
    } else if ([self numOfThumbnailPerCell] != 3){
        if(indexPath != nil) {
            indexToSelect = floor(((indexPath.row * (float)thumbnailsPerLandscapeCell) / 3.0) + 0.5);
        }
        [self setNumOfThumbnailPerCell:3];
    }
    
    [self.tableView reloadData];
    if(indexToSelect >= 0.0) {
        NSUInteger indexArr[] = {0,indexToSelect};
        NSIndexPath *newIndexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
        [self.tableView selectRowAtIndexPath:(NSIndexPath *)newIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //do nothing
}

#pragma mark -
#pragma mark Actions
- (IBAction)flipCurrentView {
    //flip the button
    [UIView transitionWithView:flipIndicatorButton  duration:0.75 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        if (self.cellStyle == kList) {
                            [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"LargeWithBack.png"] forState:UIControlStateNormal];
                            self.cellStyle = kLarge;
                        } else if (self.cellStyle == kLarge) {
                            [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"ListWithBack.png"] forState:UIControlStateNormal];
                            self.cellStyle = kList;
                        }
                    }completion:^(BOOL finished){}];
    //flip the tableview
    [UIView transitionWithView:self.view  duration:0.75 options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [[self thumbnailBuffer] removeAllObjects];
                        if (self.cellStyle == kList) {
                            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                        } else {
                            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
                        }
                        [self.tableView reloadData];
                    }completion:^(BOOL finished){}];
}

- (IBAction)organize {
	[self setEditing:YES];
	[self.tableView reloadData];
    

    self.backButtonBackup = [[self navigationItem] leftBarButtonItem];
    self.rightButtonBackup = [[self navigationItem] rightBarButtonItems];
		
    if(self.addButton == nil) {
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
        self.addButton = add;
        self.addButton.style = UIBarButtonItemStylePlain;
    }
    [[self navigationItem] setLeftBarButtonItem:self.addButton];
        
    if(self.cancelEditButton == nil) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editingDone)];
        self.cancelEditButton = cancel;
        self.cancelEditButton.style = UIBarButtonItemStyleDone;
    }
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:1];
    [buttons addObject:self.cancelEditButton];
    [[self navigationItem] setRightBarButtonItems:buttons];
}

- (IBAction)editingDone {
    [[self navigationItem] setLeftBarButtonItem:self.backButtonBackup];
    [[self navigationItem] setRightBarButtonItem:nil];
    [[self navigationItem] setRightBarButtonItems:self.rightButtonBackup animated:NO];
 
	[self setEditing:NO];
	[self.tableView reloadData];
}

- (IBAction)addPhoto {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:(id)self];
	[self presentModalViewController:imagePicker animated:YES];
}

#pragma mark -
#pragma mark File management

- (void)loadFolder:(NSString *)folder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *filenames = [fileManager contentsOfDirectoryAtPath:folder error:NULL];
	
    NSString *folderPath_ = [folder copyWithZone:nil];
	self.folderPath = folderPath_;
    self.folderTildePath = [folderPath_ stringByAbbreviatingWithTildeInPath];
    [self setTitle:[folderPath_ lastPathComponent]];
    
    NSMutableArray *folderList_ = [[NSMutableArray alloc] initWithCapacity:[filenames count]];
	self.folderList = folderList_;
    
	for(NSString *filename in filenames) {
		if([filename hasPrefix:@"."] || [filename hasPrefix:@"AC234.sqlite"] || [filename hasPrefix:@"tmp_transmit_time_offset"]) {
			//do nothing
		} else {
			NSString *filePath = [folder stringByAppendingPathComponent:filename];
			[self.folderList addObject:filePath];
		}
	}
    
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *lastViewed = [appDelegate getLastViewed:folder];
	if(lastViewed != NULL) {
		int indexToSelect = [folderList indexOfObject:lastViewed];
        NSUInteger indexArr[] = {0, indexToSelect};
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {

    NSFileManager *defaultManager = [NSFileManager defaultManager];
	NSString *filename = [self findUniqueName];
    if(filename == nil) {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"Error")
                        message: NSLocalizedString(@"NoFilenameFound", @"Error")
                        delegate: nil cancelButtonTitle: NSLocalizedString(@"Ok", @"Ok") otherButtonTitles: nil] show];
    } else {
    
        NSData *contents = UIImageJPEGRepresentation(selectedImage, 0.9f);
        if([defaultManager createFileAtPath:filename contents:(NSData *)contents attributes:nil]) {
            [self.folderList addObject:filename];
            [self.tableView reloadData];
        
            int indexToSelect = [self.folderList indexOfObject:filename];
            NSUInteger indexArr[] = {0, indexToSelect};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        } else {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"Error")
                            message: NSLocalizedString(@"CannotSaveImportedImage", @"Error")
                            delegate: nil cancelButtonTitle: NSLocalizedString(@"Ok", @"Ok") otherButtonTitles: nil] show];
        }
    }
    
	[self dismissModalViewControllerAnimated:YES];
}

-(NSString*)findUniqueName {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    for(int i=0; i<100; i++) {
		NSMutableString *potentialName = [NSMutableString stringWithCapacity:30];
		[potentialName appendString:@"img_"];
		[self generateName:i andAppendTo:potentialName];
		[potentialName appendString:@".jpg"];
		NSString *potentialPath = [folderPath stringByAppendingPathComponent:potentialName];
		if(![defaultManager fileExistsAtPath:potentialPath]) {
            return potentialPath;
        }
    }
    return NULL;
}

- (void)generateName:(int)number andAppendTo:(NSMutableString *)string {
	NSNumber *n = [NSNumber numberWithInt:number];
	NSString *s = [n stringValue];
	switch ([s length]) {
		case 1:
			[string appendString:@"000"];
			break;
		case 2:
			[string appendString:@"00"];
			break;
		case 3:
			[string appendString:@"0"];
			break;
		default:
			break;
	}
	[string appendString:s];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Navigation controller
- (void)navigationController:(UINavigationController *)navigationCtlr
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([viewController isKindOfClass:[ACFileListController class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
		[[self.navigationController navigationBar] setBarStyle:UIBarStyleBlack];
		[self.navigationController setToolbarHidden:YES animated:NO];
		
        UIApplication *sharedApp = [UIApplication sharedApplication];
        [sharedApp setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [sharedApp setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	}
}

- (void)navigationController:(UINavigationController *)navigationCtlr
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
 
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int rowIndex = [indexPath indexAtPosition:1];
    self.lastSelectedRow = rowIndex;
    
    int index;
    if([indexPath length] == 3) {
        index = [indexPath indexAtPosition:2];
    } else {
        index = 0;
    }
    
    int fileIndex = rowIndex * ([self cellStyle] == kLarge ? [self numOfThumbnailPerCell] : 1) + index;
    if(fileIndex >= 0 && fileIndex < [self.folderList count]) {
        NSString *selectedFolder = [self.folderList objectAtIndex:fileIndex];
        
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:selectedFolder isDirectory:&isDir] && !isDir) {
            [self performSegueWithIdentifier:@"MediaSegue" sender:selectedFolder];
        } else {
            if([self subController] == NULL) {
                self.subController = [[self storyboard] instantiateViewControllerWithIdentifier:@"FileListA"];
            }
            [[self navigationController] pushViewController:self.subController animated:YES];
            [self.subController loadFolder:selectedFolder];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self cellStyle] == kList) {
        return 37.0f;
    }
    return 104.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numOfThumbnails = ([self cellStyle] == kList ? 1 : [self numOfThumbnailPerCell]);
    int folderListCount = [self.folderList count];
    NSInteger numOfRow =  folderListCount/ numOfThumbnails;
    int rest = folderListCount % numOfThumbnails;
    if(rest > 0) {
        numOfRow++;
    }
    return numOfRow;
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int rowIndex = [indexPath indexAtPosition:1];
    
    if([self cellStyle] == kList) {
        ACFolderListCell *cell = (ACFolderListCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil) {
            cell = [[ACFolderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        }
        
        if(firstRowToThumbnail >= 0) {
            if(rowIndex < (firstRowToThumbnail - NUM_OF_THUMBNAILS)) {
                return cell;
            }
            firstRowToThumbnail = -1;
        }

        
        NSString *filePath = [self.folderList objectAtIndex:rowIndex];
        NSString *filename = [filePath lastPathComponent];
        [cell setFilename:filename];
        [cell setRow:rowIndex];
        [self loadThumbnailInCell:cell atRow:rowIndex forImage:filename atSize:NO];
        return cell;
        
    } else if([self cellStyle] == kLarge) {
        ACLargeThumbnailListCell *cell = (ACLargeThumbnailListCell *)[tableView dequeueReusableCellWithIdentifier:kLargeCellIdentifier];
        if (cell == nil) {
            cell = [[ACLargeThumbnailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLargeCellIdentifier];
        }
        
        if(firstRowToThumbnail >= 0) {
            if(rowIndex < (firstRowToThumbnail - (NUM_OF_THUMBNAILS / 3))) {
                return cell;
            }
            firstRowToThumbnail = -1;
        }
        int numOfThumbnails = [self numOfThumbnailPerCell];
        int thumbnailPosition = rowIndex * numOfThumbnails;
        [cell.thumbnails removeAllObjects];
        for (int i=0; i<numOfThumbnails; i++) {
            int currentThumbnail = thumbnailPosition + i;
            if(currentThumbnail < [self.folderList count]) {
                NSString *filePath = [self.folderList objectAtIndex:currentThumbnail];
                NSString *filename = [filePath lastPathComponent];
                [self loadThumbnailInCell:cell atRow:currentThumbnail forImage:filename atSize:YES];
            }
        }
        [cell setRow:rowIndex];
        return cell;
    }
    
    
    return nil;
}

- (void)loadThumbnailInCell:(UITableViewCell<ACThumbnailCell>*)cell atRow:(int)row forImage:(NSString *)filename atSize:(BOOL)large {
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
					[self fillThumbnailsBufferAt:row size:large waitUntilFilled:YES];
				}
			}
		} else {
			[self fillThumbnailsBufferAt:row size:large waitUntilFilled:YES];
		}
		thumbnail = [thumbnailBuffer objectForKey:filename];
	} else if ([thumbnailBuffer count] < PANIC_SIZE && [[[appDelegate thumbnailQueue]operations]count] == 0) {
		[self fillThumbnailsBufferAt:row size:large waitUntilFilled:NO];
	}
    
	if(thumbnail == NULL) {
		NSLog(@"Null thumbnail %@",filename);
	} else {
		[cell addThumbnail:thumbnail];
	}
	
	[thumbnailBuffer removeObjectForKey:filename];
}

- (void)fillThumbnailsBufferAt:(int)row size:(BOOL)large waitUntilFilled:(BOOL)wait {
    
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
		ACLoadThumbnailsOperation *loadBatch = [[ACLoadThumbnailsOperation alloc] initWithPath:self.folderTildePath subSet:filenames size:large];
		loadBatch.delegate = self;// set the delegate
		ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate thumbnailQueue] addOperation:loadBatch];
		if(wait) {
			[[appDelegate thumbnailQueue] waitUntilAllOperationsAreFinished];
		}
	}
}


@end
