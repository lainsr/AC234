//
//  SwitchViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 11.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ACAppDelegate.h"
#import "ACSlideViewController.h"
#import "ACFolderController.h"
#import "ACSlideViewController.h"
#import "ACToolbar.h"
#import "Folder.h"

@interface ACSlideViewController (Private) 

    @property(readwrite, strong) UIBarButtonItem *backButtonBackup;
    @property(readwrite, strong) UIBarButtonItem *rightButtonBackup;

@end

@implementation ACSlideViewController

static const int kList = 0; 
static const int kLarge = 1;
static const int kFull = 2;

UIBarButtonItem *backButtonBackup;
UIBarButtonItem *rightButtonBackup;

@synthesize folders, folderPath, folderList;
@synthesize flipIndicatorButton, cancelEditButton;
@synthesize addButton, organizeButton;
@synthesize imagesViewController, folderController, largeFolderController, navigationController, subSlideViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
		//customization
	}
	return self;
}

- (void)viewDidLoad {	
	[super viewDidLoad];
	
	// Add our organize button as the nav bar's custom right view
	UIBarButtonItem *organize = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(editFolder)];
    self.organizeButton = organize;
	self.organizeButton.style = UIBarButtonItemStyleBordered;
    
    UIButton *localFlipIndicator = [[UIButton alloc] initWithFrame:CGRectMake(0,0,32,32)];
	self.flipIndicatorButton = localFlipIndicator;
	
	// front view is always visible at first
    frontViewState = kList;
    [self.flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"list_with_back.png"] forState:UIControlStateNormal];
    [self.flipIndicatorButton addTarget:self action:@selector(flipCurrentView) forControlEvents:(UIControlEventTouchDown)];
    [self.flipIndicatorButton setOpaque:YES];
    [self.flipIndicatorButton setAlpha:1.0];

	UIBarButtonItem *sButton=[[UIBarButtonItem alloc] initWithCustomView:flipIndicatorButton];
    
    //to produce the icons
    //sButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStyleBordered target:self 
    //                                           action:@selector(flipCurrentView)];
    
    
    // create a toolbar to have two buttons in the right
    ACToolbar* tools = [[ACToolbar alloc] initWithFrame:CGRectMake(0, 0, 88, 44.01)];
    [tools setBarStyle:UIBarStyleBlackOpaque];
    
    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
    [buttons addObject:self.organizeButton];
    [buttons addObject:sButton];
    
    // stick the buttons in the toolbar
    [tools setItems:buttons animated:NO];
    
    // and put the toolbar in the nav bar
    UIBarButtonItem *toolBarItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = toolBarItem;
	
	folders = YES;
	//small thumbnails with names
    ACFolderController *folder = [[ACFolderController alloc] initWithNibName:@"ACFolderView" bundle:nil];
    self.folderController = folder;
	//large thumbnails
    ACLargeFolderController *largeFolder = [[ACLargeFolderController alloc] initWithNibName:@"ACLargeFolderView" bundle:nil];
    self.largeFolderController = largeFolder;
    
    //large images left/right scrollview
    ACScrollViewController *scrollView = [[ACScrollViewController alloc] initWithNibName:@"ACScrollView" bundle:nil];
    self.imagesViewController = scrollView;
	[self.imagesViewController setNavigationController:navigationController];
	
    if(self.folderList != NULL) {
		[self.folderController loadFolder:folderPath withImages:folderList fromSlideView:self];
		[self.largeFolderController loadFolder:folderPath withImages:folderList fromSlideView:self];
	}
	[self.view addSubview:folderController.view];
	[self.view addSubview:largeFolderController.view];
    [self.largeFolderController.view setHidden:YES];
	
	if(self.folderList != NULL && indexToSelect > 1 && indexToSelect < [self.folderList count]) {
		NSUInteger indexArr[] = {0,indexToSelect};
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
		[self.folderController startThumbnailAt:[indexPath row]];
		[self.folderController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

- (void)viewDidUnload {
	self.imagesViewController = nil;
	self.folderController = nil;
    self.largeFolderController = nil;
	self.subSlideViewController = nil;
}

- (void)willShowViewController {
	NSString *currentFile = [self.imagesViewController currentFile];
	if (currentFile != nil) {
		int toSelect = [folderList indexOfObject:currentFile];
		if (toSelect >= 0 && toSelect < [folderList count] && toSelect != [folderController indexPathForSelectedRow]) {
			NSUInteger indexArr[] = {0, toSelect};
			NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
			[self.folderController startThumbnailAt:[indexPath row]];
			[self.folderController.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
		}
	}
    
    [self.folderController updateOrientation];
    [self.largeFolderController updateOrientation];
    
    if(subSlideViewController != nil) {
		[subSlideViewController willShowParentViewController];
	}
}

- (void)willShowParentViewController {
    self.subSlideViewController.folderController.parentSlideViewController = nil;
    self.subSlideViewController.largeFolderController.parentSlideViewController = nil;
    self.subSlideViewController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.folderController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.largeFolderController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.imagesViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.folderController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.largeFolderController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.imagesViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)loadFolder:(NSString *)folder {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *filenames = [fileManager contentsOfDirectoryAtPath:folder error:NULL];
	
    NSString *folderPath_ = [folder copyWithZone:nil];
	self.folderPath = folderPath_;
    
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
	[self.folderList sortUsingFunction:finderSortWithLocale context:(__bridge void *)([NSLocale currentLocale])];

	if (self.folderController != NULL) {
		[self.folderController loadFolder:folder withImages:folderList fromSlideView:self];
	}
    if (self.largeFolderController != NULL) {
		[self.largeFolderController loadFolder:folder withImages:folderList fromSlideView:self];
	}

    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *lastViewed = [appDelegate getLastViewed:folder];
	if(lastViewed != NULL) {
		int index = [folderList indexOfObject:lastViewed];
		[self selectAtIndex:index];
	}
}

- (void)selectAtIndex:(int)index {
	if([self isViewLoaded]) {
		if(folderList != NULL && index > 1 && index < [folderList count]) {
			NSUInteger indexArr[] = {0,index};
			NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
			[folderController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
		}
	} else {
		indexToSelect = index;
	}
}

- (void)selectFile:(NSString *)file {
	[navigationController pushViewController:imagesViewController animated:YES];
	if ([folderController hasChanged]) {
		[imagesViewController loadFile:file inFolder:folderPath withContent:folderList];
		[folderController setHasChanged:NO];//consume the changes and reload the scrollview
	} else if ([folderPath isEqualToString:[imagesViewController currentDirectory]]) {
		[imagesViewController selectFile:file];
	} else {
		[imagesViewController loadFile:file inFolder:folderPath withContent:folderList];
	}
	folders = NO;
}

- (void)selectFolder:(NSString *)folder {
	if(subSlideViewController == nil) {
		subSlideViewController = [[ACSlideViewController alloc] initWithNibName:@"ACSlideView" bundle:nil];
		[subSlideViewController setNavigationController:navigationController];
	}

	[navigationController pushViewController:subSlideViewController animated:YES];
	[subSlideViewController loadFolder:folder];
	
	NSString *viewTitle = [folder lastPathComponent];
	[subSlideViewController setTitle:viewTitle];
	folders = YES;
}

- (IBAction)flipCurrentView {
	// setup the animation group
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	
	// swap the views and transition
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    if (frontViewState == kList) {
        NSString *currentFile = [folderController currentVisibleFile];
        [folderController.view setHidden:YES];
        [largeFolderController.view setHidden:NO];
        [largeFolderController selectFile:currentFile];
    } else if (frontViewState == kLarge){
        NSString *currentFile = [largeFolderController currentVisibleFile];
        [largeFolderController.view setHidden:YES];
        [folderController.view setHidden:NO];
        [folderController selectFile:currentFile];
    }

	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:flipIndicatorButton cache:YES];
	if (frontViewState == kList) {
        [flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"large_with_back.png"] forState:UIControlStateNormal];
        frontViewState = kLarge;
	} else if (frontViewState == kLarge) {
        [flipIndicatorButton setBackgroundImage:[UIImage imageNamed:@"list_with_back.png"] forState:UIControlStateNormal];
        frontViewState = kList;
	}
	[UIView commitAnimations];
}

- (IBAction)editFolder {
	BOOL editing = [folderController isEditing];
	[folderController edit];
	
	if(editing) {
		[[self navigationItem] setLeftBarButtonItem:backButtonBackup];
		[[self navigationItem] setRightBarButtonItem:rightButtonBackup];
	} else {
		backButtonBackup = [[self navigationItem] leftBarButtonItem];
		rightButtonBackup = [[self navigationItem] rightBarButtonItem];
		
		if(self.addButton == nil) {
			UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
            self.addButton = add;
			self.addButton.style = UIBarButtonItemStylePlain;
		}
		[[self navigationItem] setLeftBarButtonItem:addButton];
        
        if(self.cancelEditButton == nil) {
            UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editFolder)];
			self.cancelEditButton = cancel;
			self.cancelEditButton.style = UIBarButtonItemStyleDone;
		}
		[[self navigationItem] setRightBarButtonItem:cancelEditButton];
	}
}

- (IBAction)addPhoto {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
	NSFileManager *defaultManager = [NSFileManager defaultManager];
	BOOL found = NO;
	for(int i=0; !found; i++) {
		NSMutableString *potentialName = [NSMutableString stringWithCapacity:30];
		[potentialName appendString:@"img_"];
		[self generateName:i andAppendTo:potentialName];
		[potentialName appendString:@".jpg"];
		NSString *potentialPath = [folderPath stringByAppendingPathComponent:potentialName];
		found = ![defaultManager fileExistsAtPath:potentialPath];
		if(found) {
			NSData *contents = UIImageJPEGRepresentation(selectedImage, 0.9f);
			if([defaultManager createFileAtPath:potentialPath contents:(NSData *)contents attributes:nil]) {
				[folderList addObject:potentialPath];
				[folderList sortUsingFunction:finderSortWithLocale context:(__bridge void *)([NSLocale currentLocale])];
				[folderController loadFolder:folderPath withImages:folderList fromSlideView:self];
			
				indexToSelect = [folderList indexOfObject:potentialPath];
				NSUInteger indexArr[] = {0, indexToSelect};
				NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexArr length:2];
				[folderController startThumbnailAt:[indexPath row]];
			} else {
				NSLog(@"Failed");
			}
		}
	}
	[self dismissModalViewControllerAnimated:YES];
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
#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationCtlr
	willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	UIApplication *sharedApp = [UIApplication sharedApplication];
	if ([viewController isKindOfClass:[ACSlideViewController class]]) {
		[[navigationCtlr navigationBar] setBarStyle:UIBarStyleBlack];
		[navigationCtlr setToolbarHidden:YES animated:NO];
		[sharedApp setStatusBarStyle:UIStatusBarStyleBlackOpaque];
		[(ACSlideViewController *)viewController willShowViewController];
	} else if ([viewController isKindOfClass:[ACScrollViewController class]]) {
		[navigationCtlr setNavigationBarHidden:YES animated:NO];
		[[navigationCtlr navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
		[[navigationCtlr toolbar] setBarStyle:UIBarStyleBlackTranslucent];
		[sharedApp setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		[sharedApp setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	}
}

- (void)navigationController:(UINavigationController *)navigationCtlr
	didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

}

static NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch | NSNumericSearch | NSWidthInsensitiveSearch | NSForcedOrderingSearch;
	
static int finderSortWithLocale(id string1, id string2, void *locale) {
	//NSString *string1 = [info1 filename];
	//NSString *string2 = [info2 filename];
	NSRange string1Range = NSMakeRange(0, [string1 length]);
	return [string1 compare:string2 options:comparisonOptions range:string1Range locale:(__bridge NSLocale *)locale];
}

@end
