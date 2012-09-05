//
//  ACScroolViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 03.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <sys/stat.h>

#import "ACScrollViewController.h"
#import "ACImageViewController.h"
#import "ACMovieViewController.h"
//#import "ACDeviceManager.h"
#import "ACAppDelegate.h"
//#import "BlockActionSheet.h"

@interface ACScrollViewController (PrivateMethods)

- (void)rotateControllersToNextImage;
- (void)rotateControllersToPreviousImage;
- (UIViewController<ACController> *)replace:(UIViewController<ACController> *)viewController forFileAt:(int)index;

- (void)loadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller async:(BOOL)async;
- (void)willUnloadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller;
- (void)diUnloadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller;

- (CGRect)snapImageAt:(int)page;

- (void)sendToDevice:(int)page;

@end

@implementation ACScrollViewController

//better performance by caching a set of controllers
//@synthesize deviceToSelect;
@synthesize playButton, pauseButton, forwardButton, rewindButton, airplayButton, flexItemLeft, flexItemRight, fixItemLeft, fixItemRight;
@synthesize scrollView, pageControl, navigationController;
@synthesize prevViewController, currentViewController, nextViewController;
@synthesize pageControlUsed, rotating, kNumberOfPages, currentDirPath, filteredImageFullPathArray;
@synthesize imageController1, imageController2, imageController3;
@synthesize movieController1, movieController2, movieController3;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
		[self setHidesBottomBarWhenPushed:YES];
		[self setWantsFullScreenLayout:YES];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//toolbar
    UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play)];
	play.style = UIBarButtonItemStylePlain;
	self.playButton = play;

	
    UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause)];
	self.pauseButton = pause;
	self.pauseButton.style = UIBarButtonItemStylePlain;
	
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(next:)];
	self.forwardButton = forward;
	self.forwardButton.style = UIBarButtonItemStylePlain;
	
    UIBarButtonItem *rewind = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previous:)];
	self.rewindButton = rewind;
	self.rewindButton.style = UIBarButtonItemStylePlain;
    
    UIImage *airplayIcon;
    //ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	//ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if(YES /*[deviceManager deviceAvailable]*/) {
        airplayIcon = [UIImage imageNamed:@"display_on.png"];
    } else {
        airplayIcon = [UIImage imageNamed:@"display_off.png"];
    }

    UIBarButtonItem *airplay = [[UIBarButtonItem alloc] initWithImage:airplayIcon style:UIBarButtonItemStylePlain target:self action:@selector(airplay)];
	self.airplayButton = airplay;

    UIBarButtonItem *flexLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	self.flexItemLeft = flexLeft;
	
    UIBarButtonItem *flexRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.flexItemRight = flexRight;
	
    UIBarButtonItem *fixLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	self.fixItemLeft = fixLeft;
	[self.fixItemLeft setWidth:26.0f];
	
    UIBarButtonItem *fixRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.fixItemRight = fixRight;
	[self.fixItemRight setWidth:18.0f];
	
	NSArray *items = [NSArray arrayWithObjects: flexItemLeft, rewindButton, fixItemLeft, playButton, fixItemRight, forwardButton, flexItemRight, airplayButton, nil];
	[self setToolbarItems:items animated:NO];
	
	// a page is the width of the scroll view
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.delegate = self;
	
    //allocate the pool of image controllers
    /*
    ACImageViewController *ctrl1 = [[ACImageViewController alloc] init];
	self.imageController1 = ctrl1;
	[self.imageController1 setNavigationController:self.navigationController];
	
    ACImageViewController *ctrl2 = [[ACImageViewController alloc] init];
    self.imageController2 = ctrl2;
	[self.imageController2 setNavigationController:self.navigationController];
	
    ACImageViewController *ctrl3 = [[ACImageViewController alloc] init];
    self.imageController3 = ctrl3;
	[self.imageController3 setNavigationController:self.navigationController];
	//allocate the pool of movie controllers
	
    ACMovieViewController *ctrl4 = [[ACMovieViewController alloc] init];
    self.movieController1 = ctrl4;
	[self.movieController1 setNavigationController:self.navigationController];
	
    ACMovieViewController *ctrl5 = [[ACMovieViewController alloc] init];
    self.movieController2 = ctrl5;
	[movieController2 setNavigationController:self.navigationController];
	
    ACMovieViewController *ctrl6 = [[ACMovieViewController alloc] init];
    self.movieController3 = ctrl6;
	[self.movieController3 setNavigationController:self.navigationController];
    */
	
	[self setWantsFullScreenLayout:YES];
}

- (void)viewDidUnload {
	self.scrollView = nil;
	[super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setLastViewed:[self currentFile]];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self clearViewControllers];
	[self pause];
}

- (void)clearViewControllers {
	[self.imageController1 clearView];
	[self.imageController2 clearView];
	[self.imageController3 clearView];
	[self.movieController1 clearView];
	[self.movieController2 clearView];
	[self.movieController3 clearView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	rotating = YES;
	[self.nextViewController clearView];
	[self.prevViewController clearView];
	[self.currentViewController updateViewAfterOrientationChange:YES];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	self.scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * pageControl.currentPage, 0);
	self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * pageControl.numberOfPages, 200);
	
	self.currentViewController.view.frame = [self snapImageAt:pageControl.currentPage];
	self.nextViewController.view.frame = [self snapImageAt:pageControl.currentPage + 1];
	self.prevViewController.view.frame = [self snapImageAt:pageControl.currentPage - 1];
	
	[self.nextViewController updateViewAfterOrientationChange:YES];
	[self.prevViewController updateViewAfterOrientationChange:YES];
	
	self.rotating = NO;

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark -
#pragma mark Slide show
- (void)play {
	[self.imageController1 hideHUDView];
	[self.imageController2 hideHUDView];
	[self.imageController3 hideHUDView];
	[self.movieController1 hideHUDView];
	[self.movieController2 hideHUDView];
	[self.movieController3 hideHUDView];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	CGFloat interval = 5.0;
	myTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(next:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
	
	NSArray *items = [NSArray arrayWithObjects: flexItemLeft, rewindButton, fixItemLeft, pauseButton, fixItemRight, forwardButton, flexItemRight, airplayButton, nil];
	[self setToolbarItems:items animated:NO];
}

-(void)pause {
	if(myTimer == nil) return;
	[myTimer invalidate];
	myTimer = nil;
	
	NSArray *items = [NSArray arrayWithObjects: flexItemLeft, rewindButton, fixItemLeft, playButton, fixItemRight, forwardButton, flexItemRight, airplayButton, nil];
	[self setToolbarItems:items animated:NO];
}

- (void)next:(NSTimer *)timer {
	int nextIndex = self.pageControl.currentPage + 1;
	if(filteredImageFullPathArray != nil && nextIndex >= 0 && nextIndex < [filteredImageFullPathArray count]) {
		pageControl.currentPage = nextIndex;
	} else {
		pageControl.currentPage = 0;
	}
	
	pageControlUsed = YES;
	[self rotateControllersToNextImage];
	CGRect frame = [self snapImageAt:pageControl.currentPage];
	[scrollView scrollRectToVisible:frame animated:YES];
    [self sendToDevice:pageControl.currentPage];
}

- (void)previous:(NSTimer *)timer {
	int previousIndex = pageControl.currentPage - 1;
	if(filteredImageFullPathArray != nil && previousIndex >= 0 && previousIndex < [filteredImageFullPathArray count]) {
		pageControl.currentPage = previousIndex;
	} else {
		pageControl.currentPage = 0;
	}
	
	pageControlUsed = YES;
	[self rotateControllersToPreviousImage];
	CGRect frame = [self snapImageAt:pageControl.currentPage];
	[scrollView scrollRectToVisible:frame animated:YES];
    [self sendToDevice:pageControl.currentPage];
}

- (void)airplay {
    /*ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if([deviceManager deviceAvailable]) {
        [deviceManager addDeviceConnectionDelegate:self];
        [deviceManager stop];
    } else {
        [deviceManager addDeviceConnectionDelegate:self];
        [deviceManager autoConnect];
    }*/
}
/*
#pragma mark -
#pragma mark ACDeviceManagerDelegate
-(void)deviceDetected:(ACDevice *)device {
    if(![NSThread isMainThread]) {
        
    }
    
    [self setDeviceToSelect:device];
    NSString *cancelStr = NSLocalizedString(@"cancel", "Cancel");

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                   delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    
    [actionSheet addButtonWithTitle:[device displayName]];
    [actionSheet addButtonWithTitle:@"iPhone"];
    [actionSheet addButtonWithTitle:cancelStr];
    [actionSheet setCancelButtonIndex:2];
	[actionSheet showInView:self.view];
	[actionSheet release];
 
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:NULL];
    [sheet addButtonWithTitle:[device displayName] block:^{
        [self actionSheetCancel:nil];
    }];
    [sheet addButtonWithTitle:@"iPhone" block:^{
        [self actionSheetCancel:nil];
    }];
    [sheet setCancelButtonWithTitle:cancelStr block:nil];
    [sheet showInView:self.view];
}*/

-(void)deviceConnected {
    UIImage *airplayIcon = [UIImage imageNamed:@"display_on.png"];
    [self.airplayButton setImage:airplayIcon];
    
    if([NSThread isMainThread]) {
        NSLog(@"Connect on main thread");
    }
    
    
    [self sendToDevice:pageControl.currentPage];
}

-(void)deviceDisconnected {
    UIImage *airplayIcon = [UIImage imageNamed:@"display_off.png"];
    [self.airplayButton setImage:airplayIcon];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   /* AC234AppDelegate *appDelegate = (AC234AppDelegate *)[[UIApplication sharedApplication] delegate];
    ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if(buttonIndex == 0) {
        [deviceManager connectToDevice:[self deviceToSelect]];
    } else if (buttonIndex == 1) { 
        [deviceManager stop];
    }*/
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    
}

#pragma mark -
#pragma mark ACScrollViewController
- (NSString *)currentFile {
	int index = pageControl.currentPage;
	if(filteredImageFullPathArray != nil && index >= 0 && index < [filteredImageFullPathArray count]) {
		return [filteredImageFullPathArray objectAtIndex: pageControl.currentPage];
	}
	return nil;
}

- (NSString *)currentDirectory {
	return currentDirPath;
}

- (void)loadFile:(NSString *)file inFolder:(NSString*)dirPath withContent:(NSMutableArray *)imageFullPathArray {

	if(currentDirPath == nil || ![currentDirPath isEqualToString:dirPath]) {
		struct stat st_buf;
		NSMutableArray *filteredList = [[NSMutableArray alloc] initWithCapacity:[imageFullPathArray count]];
        self.filteredImageFullPathArray = filteredList;
		
        for(NSString *imageFullPath in imageFullPathArray) {
			const char *cPath = [imageFullPath cStringUsingEncoding:NSUTF8StringEncoding];
            stat (cPath , &st_buf);
			if (!S_ISDIR (st_buf.st_mode)) {
                NSString *copy = [imageFullPath copyWithZone:nil];
				[filteredImageFullPathArray addObject: copy];
			}
		}
		if(dirPath == nil) {
            self.currentDirPath = nil; 
        } else {
            NSString *newDirPath = [dirPath copyWithZone:nil];
            self.currentDirPath = newDirPath;
        }
        
        kNumberOfPages = [filteredImageFullPathArray count];
		
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, 200);
		pageControl.numberOfPages = kNumberOfPages;
		[imageController1 setNumberOfPages:kNumberOfPages];
		[imageController2 setNumberOfPages:kNumberOfPages];
		[imageController3 setNumberOfPages:kNumberOfPages];
		[movieController1 setNumberOfPages:kNumberOfPages];
		[movieController2 setNumberOfPages:kNumberOfPages];
		[movieController3 setNumberOfPages:kNumberOfPages];
	}

	int index = 0;
	if(file != nil) {
		int count = 0;
		for(NSString *imageFullPath in filteredImageFullPathArray) {
			if (file != nil && [file isEqualToString:imageFullPath]) {
					index = count;
					break;
			}
			count++;
		}
	}
	pageControl.currentPage = index;
	
	//init with the most common
	currentViewController = imageController1;
	prevViewController = imageController2;
	nextViewController = imageController3;
	
	//check
	prevViewController = [self replace:prevViewController forFileAt:index-1];
	currentViewController = [self replace:currentViewController forFileAt:index];
	nextViewController = [self replace:nextViewController forFileAt:index+1];
	
	[self loadScrollViewWithPage:index controller:currentViewController async:NO];
	if(index >= 0) {
		CGRect frame = [self snapImageAt:index];
		[scrollView scrollRectToVisible:frame animated:NO];
	}
	//preload the previous and next images
	[self loadScrollViewWithPage:index + 1 controller:nextViewController async:YES];
	[self loadScrollViewWithPage:index - 1 controller:prevViewController async:YES];
    //push the file to devices
    [self sendToDevice:index];
}

- (void)selectFile:(NSString *)file {
	int index = 0;
	if(file != nil) {
		int count = 0;
		for(NSString *imageFullPath in filteredImageFullPathArray) {
			if (file != nil && [file isEqualToString:imageFullPath]) {
					index = count;
					break;
			}
			count++;
		}
	}

	pageControl.currentPage = index;
	// load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
	[self loadScrollViewWithPage:index controller:currentViewController async:NO];
	[self loadScrollViewWithPage:index - 1 controller:prevViewController async:YES];
	[self loadScrollViewWithPage:index + 1 controller:nextViewController async:YES];
	// update the scroll view to the appropriate page
	CGRect frame = [self snapImageAt:index];
	[scrollView scrollRectToVisible:frame animated:NO];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
	pageControlUsed = NO;
    
    //push the file to devices
    [self sendToDevice:index];
}

- (IBAction)changePage:(id)sender {
	int page = pageControl.currentPage;
	// load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
	[self loadScrollViewWithPage:page controller:currentViewController async:NO];
	[self loadScrollViewWithPage:page - 1 controller:prevViewController async:YES];
	[self loadScrollViewWithPage:page + 1 controller:nextViewController async:YES];
	// update the scroll view to the appropriate page
	CGRect frame = [self snapImageAt:page];
	[scrollView scrollRectToVisible:frame animated:YES];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
	pageControlUsed = NO;
    
    //push the file to devices
    [self sendToDevice:page];
}

- (void)willUnloadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller {
	if (page < 0) return;
	if (page >= [filteredImageFullPathArray count]) return;
	
	NSString *imagePath = [filteredImageFullPathArray objectAtIndex:page];
	[controller willUnload:imagePath at:page];
}

- (void)didUnloadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller {
	if (page < 0) return;
	if (page >= [filteredImageFullPathArray count]) return;
	
	NSString *imagePath = [filteredImageFullPathArray objectAtIndex:page];
	[controller didUnload:imagePath at:page];
}

- (void)loadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller async:(BOOL)async {
	if (page < 0) return;
	if (page >= [filteredImageFullPathArray count]) return;

	//clip the image view at the right place
	CGRect snapTo = [self snapImageAt:page];
	if(!CGRectEqualToRect(snapTo, controller.view.frame)) {
		controller.view.frame = snapTo;
	}
	if (nil == controller.view.superview) {
		//add the controller's view to the scroll view
		[scrollView addSubview:controller.view];
	} else if (scrollView != controller.view.superview) {
		//not the right scroll view, readd it
		[scrollView addSubview:controller.view];
	}
	
	// replace the placeholder if necessary
	NSString *imagePath = [filteredImageFullPathArray objectAtIndex:page];
	if(async) {
		[controller willLoad:imagePath at:page];
	} else {
		[controller didLoad:imagePath at:page];
	}
}

- (UIViewController<ACController> *)replace:(UIViewController<ACController> *)viewController forFileAt:(int)index {
	if(index < 0 || index >= [filteredImageFullPathArray count]) {
		return viewController;
	}
	
	int poolPosition = 1;
	if([viewController isEqual:imageController2] || [viewController isEqual:movieController2]) {
		poolPosition = 2;
	} else if([viewController isEqual:imageController3] || [viewController isEqual:movieController3]) {
		poolPosition = 3;
	}
	
	NSString *imagePath = [filteredImageFullPathArray objectAtIndex:index];
	NSString *extension = [[imagePath pathExtension] lowercaseString];
	UIViewController<ACController> * replacementController = NULL;
	if([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"m4v"] || [extension isEqualToString:@"mpg"] || [extension isEqualToString:@"mov"]) {
		switch (poolPosition) {
			case 1: replacementController = movieController1; break;
			case 2: replacementController = movieController2; break;
			case 3: replacementController = movieController3; break;
			default: NSLog(@"Movie pool exhausted");
		}
	} else if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
		switch (poolPosition) {
			case 1: replacementController = imageController1; break;
			case 2: replacementController = imageController2; break;
			case 3: replacementController = imageController3; break;
			default: NSLog(@"Image pool exhausted");
		}
	}
	
	if(replacementController == NULL) {
		return NULL;
	}
	if(![viewController isEqual:replacementController]) {
		[viewController.view removeFromSuperview];
	}
	return replacementController;
}

- (CGRect)snapImageAt:(int)page {
	CGRect frame = scrollView.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	return frame;
}


- (void)sendToDevice:(int)page {
    //todo try to push the content a connected device
    /*AC234AppDelegate *appDelegate = (AC234AppDelegate *)[[UIApplication sharedApplication] delegate];
	ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if([deviceManager deviceAvailable]) {
        NSString *imagePath = [filteredImageFullPathArray objectAtIndex:page];
        [deviceManager pushFileToDevice:imagePath];
    }*/
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
	// We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
	// which a scroll event generated from the user hitting the page control triggers updates from
	// the delegate method. We use a boolean to disable the delegate logic when the page control is used.
	if (pageControlUsed || rotating) {
		// do nothing - the scroll was initiated from the page control, not the user dragging
		return;
	}

	// Switch the indicator when more than 50% of the previous/next page is visible
	CGFloat pageWidth = scrollView.frame.size.width;
	int currentPage = pageControl.currentPage;
    float pageFraction = scrollView.contentOffset.x / pageWidth;

    int page = 0;
    if(currentPageFraction > pageFraction) {
        //go previous
        page  = ceil(pageFraction);
        if((pageFraction - page) < -0.95) { 
            page--;
        }
    } else if (pageFraction > currentPageFraction) {
        //go next
        page  = floor(pageFraction);
        if((pageFraction - page) > 0.95) { 
            page++;
        }
    }
    
    if(page < 0) {
        page = 0;
    } else if (page >= pageControl.numberOfPages) {
        page = pageControl.numberOfPages -1;
    }
 
    currentPageFraction = pageFraction;
    if(page != currentPage) {
		pageControl.currentPage = page;
	}
	
	if(page > currentPage) {
		//next
		[self rotateControllersToNextImage];
	} else if (page < currentPage) {
		//previous
		[self rotateControllersToPreviousImage];
	}
    
    if(page != currentPage) {
        [self sendToDevice:page];
    }
}

- (void)rotateControllersToNextImage {
	int page = pageControl.currentPage;
	UIViewController<ACController> *tempViewController = prevViewController;
	[self didUnloadScrollViewWithPage:page - 2 controller:prevViewController];
	prevViewController = currentViewController;
	currentViewController = nextViewController;
	nextViewController = [self replace:tempViewController forFileAt:page + 1];
	[self loadScrollViewWithPage:page controller:currentViewController async:YES];
	[self loadScrollViewWithPage:page + 1 controller:nextViewController async:YES];
	[self willUnloadScrollViewWithPage:page - 1 controller:prevViewController];
}

- (void)rotateControllersToPreviousImage {
	int page = pageControl.currentPage;
	UIViewController<ACController> *tempViewController = nextViewController;
	[self didUnloadScrollViewWithPage:page + 2 controller:nextViewController];
	nextViewController = currentViewController;
	currentViewController = prevViewController;
	prevViewController = [self replace:tempViewController forFileAt:page - 1];
	[self loadScrollViewWithPage:page controller:currentViewController async:YES];
	[self loadScrollViewWithPage:page - 1 controller:prevViewController async:YES];
	[self willUnloadScrollViewWithPage:page + 1 controller:nextViewController];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if(rotating) {
		return;
	}
	
	pageControlUsed = NO;
}

@end
