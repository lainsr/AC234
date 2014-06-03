//
//  ACFileListController.m
//  AC234
//
//  Created by Stéphane Rossé on 02.09.12.
//
//
#import "ACScaler.h"
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
- (ACLargeThumbnailListCell *)loadLineOfLargeThumbnails:(UITableView *)tableView cellForRowAtIndex:(int)rowIndex;
- (ACFolderListCell *)loadSingleSmallThumbnail:(UITableView *)tableView cellForRowAtIndex:(int)rowIndex;

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
    
    if(self.folderList == NULL) {
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setFolderTildePath:[appDelegate applicationDocumentsDirectory]];
        [self setTitle:@"Home"];
        [self loadFolder:[self folderTildePath]]; 
    }
    
    self.flipIndicatorButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,22,22)];
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
		[[self.navigationController navigationBar] setTranslucent:YES];
        //[[self.navigationController toolbar] setBarStyle:UIBarStyleDefault];
        [[self.navigationController toolbar] setTranslucent:YES];
        //prepare the toolbar but hide it
        [self.navigationController setToolbarHidden:YES animated:NO];
		[self.navigationController setDelegate:self];
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
	[self presentViewController:imagePicker animated:YES completion:^(){}];
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
    
    self.folderList = [[NSMutableArray alloc] initWithCapacity:[filenames count]];
	
	for(NSString *filename in filenames) {
		if([filename hasPrefix:@"."] || [filename hasPrefix:@"AC234.sqlite"] || [filename hasPrefix:@"tmp_transmit_time_offset"]) {
			//do nothing
		} else {
			NSString *filePath = [folder stringByAppendingPathComponent:filename];
			[self.folderList addObject:filePath];
		}
	}
    static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch;
    
    //order by name
    [self.folderList sortUsingComparator:^NSComparisonResult(NSString *string1, NSString *string2) {
        return [string1 compare:string2 options:comparisonOptions];
    }];

    [self.tableView reloadData];
    
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *lastViewed = [appDelegate getLastViewed:folder];
	if(lastViewed != NULL) {
		int indexToSelect = [self.folderList indexOfObject:lastViewed];
        if(indexToSelect >= 0 && indexToSelect < [self.tableView numberOfRowsInSection:0]) {
            NSUInteger indexArr[] = {0, indexToSelect};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
	}
}


- (void)clear {
    [self setFolderPath:NULL];
    [self setFolderTildePath:NULL];
    [self.folderList removeAllObjects];
    [self.thumbnailBuffer removeAllObjects];
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
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

#pragma mark -
#pragma mark Navigation controller
- (void)navigationController:(UINavigationController *)navigationCtlr
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([viewController isKindOfClass:[ACFileListController class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
		[[self.navigationController navigationBar] setTranslucent:NO];
		[self.navigationController setToolbarHidden:YES animated:NO];
		
        UIApplication *sharedApp = [UIApplication sharedApplication];
        [sharedApp setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	}
}

- (void)navigationController:(UINavigationController *)navigationCtlr
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
 //
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger rowIndex = [indexPath indexAtPosition:1];
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
            } else {
                [self.subController clear];
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
    
    UITableViewCell *cell;
    if([self cellStyle] == kList) {
        cell = [self loadSingleSmallThumbnail:tableView cellForRowAtIndex:rowIndex];
    } else if([self cellStyle] == kLarge) {
        cell = [self loadLineOfLargeThumbnails:tableView cellForRowAtIndex:rowIndex];
    }
    return cell;
}

- (ACFolderListCell *)loadSingleSmallThumbnail:(UITableView *)tableView cellForRowAtIndex:(int)rowIndex {
    ACFolderListCell *cell = (ACFolderListCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[ACFolderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    } else {
        [cell addThumbnail:NULL];
    }
    
    if(firstRowToThumbnail >= 0) {
        if(rowIndex < (firstRowToThumbnail - NUM_OF_THUMBNAILS)) {
            return cell;
        }
        firstRowToThumbnail = -1;
    }
    
    //a security
    if([self.folderList count] <= rowIndex) {
        rowIndex = [self.folderList count] - 1;
    }
    
    NSString *filePath = [self.folderList objectAtIndex:rowIndex];
    NSString *filename = [filePath lastPathComponent];
    [cell setFilename:filename];
    [cell setRow:rowIndex];
    
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

        UIImage *thumbnail = [ACScaler scale:localContext atFolderPath:self.folderTildePath image:filename size:NO];
     
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(thumbnail == NULL) {
                NSLog(@"Null thumbnail %@",filename);
            } else if([cell.filename isEqualToString:filename]) {
                [cell addThumbnail:thumbnail];
                [cell setNeedsLayout];
            }
        }];
    }];
    
    return cell;
}


- (ACLargeThumbnailListCell *)loadLineOfLargeThumbnails:(UITableView *)tableView cellForRowAtIndex:(int)rowIndex {
    ACLargeThumbnailListCell *cell = (ACLargeThumbnailListCell *)[tableView dequeueReusableCellWithIdentifier:kLargeCellIdentifier];
    if (cell == nil) {
        cell = [[ACLargeThumbnailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLargeCellIdentifier];
    } else {
        [cell removeAllThumbnails];
    }
    
    int numOfThumbnails = [self numOfThumbnailPerCell];
    if(firstRowToThumbnail >= 0) {
        if(rowIndex < (firstRowToThumbnail - (NUM_OF_THUMBNAILS / numOfThumbnails))) {
            return cell;
        }
        firstRowToThumbnail = -1;
    }
    
    int thumbnailPosition = rowIndex * numOfThumbnails;
    NSMutableArray *filenames = [NSMutableArray arrayWithCapacity:numOfThumbnails];
    for (int i=0; i<numOfThumbnails; i++) {
        int currentThumbnail = thumbnailPosition + i;
        if(currentThumbnail < [self.folderList count]) {
            NSString *filePath = [self.folderList objectAtIndex:currentThumbnail];
            NSString *filename = [filePath lastPathComponent];
            [filenames addObject:filename];
        }
    }
    [cell setFirstFilename:[filenames objectAtIndex:0]];
    [cell setRow:rowIndex];
    
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
        
        NSArray *thumbnails = [ACScaler scale:localContext atFolderPath:self.folderTildePath subSet:filenames size:YES];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSString *firstFilename = [filenames objectAtIndex:0];
            if(thumbnails == NULL) {
                NSLog(@"Null thumbnails");
            } else if([cell.firstFilename isEqualToString:firstFilename]) {
                [[cell thumbnails] removeAllObjects];
                [[cell thumbnails] addObjectsFromArray:thumbnails];
                [cell setNeedsLayout];
            }
        }];
    }];
    
    return cell;
}

-(void) thumbnailFinished:(UIImage*)image forFile:(NSString*)filename {
	[super thumbnailFinished:image forFile:filename];
}


@end
