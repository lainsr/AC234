//
//  ACScroolViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 03.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include <sys/stat.h>

#import "ACScrollViewController.h"
#import "ACHThumbnailViewController.h"
#import "ACImageViewController.h"
#import "ACMovieViewController.h"
#import "ACDeviceManager.h"
#import "ACAppDelegate.h"

@interface ACScrollViewController (PrivateMethods)

- (void)rotateControllersToNextImage;
- (void)rotateControllersToPreviousImage;
- (UIViewController<ACController> *)replace:(UIViewController<ACController> *)viewController forFileAt:(int)index;

- (void)loadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller async:(BOOL)async;
- (void)willUnloadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller;
- (void)diUnloadScrollViewWithPage:(int)page controller:(UIViewController<ACController> *)controller;

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture;
- (void)pushTheMainScrollView:(UISwipeGestureRecognizer *)gesture;
- (void)popTheMainScrollView:(UISwipeGestureRecognizer *)gesture;

- (CGRect)snapImageAt:(int)page;

- (void)sendToDevice:(int)page;

@end

@implementation ACScrollViewController

@synthesize deviceToSelect;

@synthesize playButton, pauseButton, forwardButton, rewindButton, airplayButton, flexItemLeft, flexItemRight, fixItemLeft, fixItemRight;
@synthesize scrollView, pageControl, miniContainerView;
@synthesize informations, informationsHud;
@synthesize prevViewController, currentViewController, nextViewController;
@synthesize pageControlUsed, rotating, currentDirPath, selectedFile, filteredImageFullPathArray;
//better performance by caching a set of controllers
@synthesize imageController1, imageController2, imageController3;
@synthesize movieController1, movieController2, movieController3;

- (void)viewDidLoad {
	[super viewDidLoad];
    
    NSArray *items = [NSArray arrayWithObjects: flexItemLeft, rewindButton, fixItemLeft, playButton, fixItemRight, forwardButton, flexItemRight, airplayButton, nil];
	[self setToolbarItems:items animated:NO];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [singleTap setDelegate:self];
    [self.scrollView addGestureRecognizer:singleTap];

    UISwipeGestureRecognizer *pushTap =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pushTheMainScrollView:)];
    [pushTap setDirection:UISwipeGestureRecognizerDirectionUp];
    [pushTap setDelegate:self];
    [self.scrollView addGestureRecognizer:pushTap];
    
    UISwipeGestureRecognizer *popTap =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popTheMainScrollView:)];
    [popTap setDirection:UISwipeGestureRecognizerDirectionDown];
    [popTap setDelegate:self];
    [self.scrollView addGestureRecognizer:popTap];
    
    [self.informationsHud setHidden:YES];
	
	// a page is the width of the scroll view
	self.scrollView.pagingEnabled = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.delegate = self;
	
    //allocate the pool of image controllers
    self.imageController1 = [[self storyboard] instantiateViewControllerWithIdentifier:@"ImageView"];
    self.imageController2 = [[self storyboard] instantiateViewControllerWithIdentifier:@"ImageView"];
    self.imageController3 = [[self storyboard] instantiateViewControllerWithIdentifier:@"ImageView"];
    //allocate the pool of movie controllers
    self.movieController1 = [[self storyboard] instantiateViewControllerWithIdentifier:@"MovieView"];
    self.movieController2 = [[self storyboard] instantiateViewControllerWithIdentifier:@"MovieView"];
    self.movieController3 = [[self storyboard] instantiateViewControllerWithIdentifier:@"MovieView"];
    [self.movieController1 setScrollViewNavigation:[self navigationController]];
    [self.movieController2 setScrollViewNavigation:[self navigationController]];
    [self.movieController3 setScrollViewNavigation:[self navigationController]];
    
	[self setWantsFullScreenLayout:YES];
    [self load];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setLastViewed:[self currentFile]];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self clearViewControllers];
    
    [self.movieController1 setScrollViewNavigation:nil];
    [self.movieController2 setScrollViewNavigation:nil];
    [self.movieController3 setScrollViewNavigation:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destinationController = [segue destinationViewController];
    if([destinationController isKindOfClass: [ACHThumbnailViewController class]]) {
        ACHThumbnailViewController *collectionController = (ACHThumbnailViewController*)destinationController;
        [collectionController setFolderList:[self filteredImageFullPathArray]];
        [collectionController setFolderTildePath:[self currentDirPath]];
    }  
}

/**
 * Reload the image if the app was put to sleep
 **/
- (void)viewWillAppear:(BOOL)animated {
	if([self.currentViewController empty]) {
        int page = pageControl.currentPage;
        [self loadScrollViewWithPage:page controller:currentViewController async:YES];
    }
    
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if([deviceManager deviceAvailable]) {
        UIImage *airplayIcon = [UIImage imageNamed:@"DisplayOn.png"];
        [self.airplayButton setImage:airplayIcon];
    }
}

#pragma mark -
#pragma mark HUD view
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    if([gesture state] == UIGestureRecognizerStateEnded) {
        [self popTheMainScrollView:nil];
        [self toggleInformations];
    }
}

/**
 *
 **/
- (void)pushTheMainScrollView:(UISwipeGestureRecognizer *)gesture {
    [self hideHUDView];
    CGRect currentPosition = self.scrollView.frame;
    if(currentPosition.origin.y == 0) {
        [UIView transitionWithView:self.view  duration:0.1 options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        self.scrollView.frame = CGRectMake(currentPosition.origin.x, currentPosition.origin.y - 120, currentPosition.size.width, currentPosition.size.height);

                    }completion:^(BOOL finished){}];
    }
}

- (void)popTheMainScrollView:(UISwipeGestureRecognizer *)gesture {
    CGRect currentPosition = self.scrollView.frame;
    if(currentPosition.origin.y != 0) {
        [UIView transitionWithView:self.view  duration:0.1 options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        self.scrollView.frame = CGRectMake(0, 0, currentPosition.size.width, currentPosition.size.height);
                        
                    }completion:^(BOOL finished){}];
    }
}

/**
 * http://stackoverflow.com/questions/8957876/how-to-pass-touchupinside-event-to-a-uibutton-without-passing-it-to-parent-view
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *gestureView = gestureRecognizer.view;
    // gestureView is the view that the recognizer is attached to - should be the scroll view
    
    CGPoint point = [touch locationInView:gestureView];
    UIView *touchedView = [gestureView hitTest:point withEvent:nil];
    // touchedView is the deepest descendant of gestureView that contains point
    
    // Block the recognizer if touchedView is a UIButton, or a descendant of a UIButton
    while (touchedView && touchedView != gestureView) {
        if ([touchedView isKindOfClass:[UIButton class]]) {
            return NO;
        }
        touchedView = touchedView.superview;
    }
    return YES;
}

- (void)hideHUDView {
	if (informationsHud.hidden) return;
	
	informationsHud.alpha = 0.00;
    informationsHud.hidden = YES;
	
    UIApplication *sharedApp = [UIApplication sharedApplication];
	[sharedApp setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)toggleInformations {
	if(myTimer != nil) {
		[myTimer invalidate];
		myTimer = nil;
	}
	
	if (informationsHud.hidden) {
		NSString *fileName = [[self currentFile] lastPathComponent];
		if(fileName == nil) {
			[self hideHUDView];
		} else {
			NSMutableString *infos = [[NSMutableString alloc] initWithString:fileName];
			[infos appendString:@"\n"];
			[infos appendFormat:@"%i",[pageControl currentPage]];
			[infos appendString:@" / "];
			[infos appendFormat:@"%i",[pageControl numberOfPages]];
            
			self.informations.text = infos;
			self.informationsHud.hidden = NO;
			self.informationsHud.alpha = 0.00;//usefull for the first time only
            
            myTimer = [NSTimer timerWithTimeInterval:0.15 target:self selector:@selector(showHUDView:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
            
            UIApplication *sharedApp = [UIApplication sharedApplication];
			[sharedApp setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
			[sharedApp setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
			[self.navigationController setNavigationBarHidden:NO animated:YES];
			[self.navigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
			[self.navigationController setToolbarHidden:NO animated:YES];
		}
	} else {
		[self hideHUDView];
	}
}

- (void)showHUDView:(NSTimer *)timer {
    [UIView transitionWithView:self.scrollView  duration:0.1 options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        self.informationsHud.alpha = 1.0;
                        self.informationsHud.hidden = NO;
                        [self clipHUDView];
                    }completion:^(BOOL finished){}];
}

- (void)clipHUDView {
    CGRect navFrame = [self.navigationController.navigationBar frame];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        informationsHud.frame = CGRectMake(0, 20 + navFrame.size.height, navFrame.size.width, 44);
    } else {
        informationsHud.frame = CGRectMake(0, 20 + navFrame.size.height, navFrame.size.width, 64);
    }
}

#pragma mark -
#pragma mark Slide show
- (IBAction)play {
    [self hideHUDView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    myTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(next) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
        
    NSArray *items = [NSArray arrayWithObjects: flexItemLeft, rewindButton, fixItemLeft, pauseButton, fixItemRight, forwardButton, flexItemRight, airplayButton, nil];
	[self setToolbarItems:items animated:NO];
}

-(IBAction)pause {
    [myTimer invalidate];
    myTimer = nil;
    
    NSArray *items = [NSArray arrayWithObjects: flexItemLeft, rewindButton, fixItemLeft, playButton, fixItemRight, forwardButton, flexItemRight, airplayButton, nil];
	[self setToolbarItems:items animated:NO];
}

- (IBAction)next {
    [self hideHUDView];
    
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

- (IBAction)previous{
    [self hideHUDView];
    
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

- (IBAction)airplay {
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if([deviceManager deviceAvailable]) {
        [deviceManager addDeviceConnectionDelegate:self];
        [deviceManager stop];
    } else {
        [deviceManager addDeviceConnectionDelegate:self];
        [deviceManager autoConnect];
    }
}

#pragma mark -
#pragma mark ACDeviceManagerDelegate
-(void)deviceDetected:(ACDevice *)device {
    [self setDeviceToSelect:device];
    NSString *cancelStr = NSLocalizedString(@"cancel", "Cancel");

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                   delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.delegate = self;
    
    [actionSheet addButtonWithTitle:[device displayName]];
    [actionSheet addButtonWithTitle:@"iPhone"];
    [actionSheet addButtonWithTitle:cancelStr];
    [actionSheet setCancelButtonIndex:2];
	[actionSheet showInView:self.view];
}

-(void)deviceConnected {
    UIImage *airplayIcon = [UIImage imageNamed:@"DisplayOn.png"];
    [self.airplayButton setImage:airplayIcon];
    
    if([NSThread isMainThread]) {
        NSLog(@"Connect on main thread");
    }
    
    [self sendToDevice:pageControl.currentPage];
}

- (void)sendToDevice:(int)page {
    //todo try to push the content a connected device
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if([deviceManager deviceAvailable]) {
        NSString *imagePath = [filteredImageFullPathArray objectAtIndex:page];
        [deviceManager pushFileToDevice:imagePath];
    }
}

-(void)deviceDisconnected {
    UIImage *airplayIcon = [UIImage imageNamed:@"DisplayOff.png"];
    [self.airplayButton setImage:airplayIcon];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    ACDeviceManager *deviceManager = [appDelegate deviceManager];
    if(buttonIndex == 0) {
        [deviceManager connectToDevice:[self deviceToSelect]];
    } else if (buttonIndex == 1) { 
        [deviceManager stop];
    }
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


- (void)setFile:(NSString *)file inFolder:(NSString*)dirPath withContent:(NSMutableArray *)imageFullPathArray {
    [self setSelectedFile:file];
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
	}
}

- (void)load {
    int kNumberOfPages = [filteredImageFullPathArray count];

    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, 200);
    self.pageControl.numberOfPages = kNumberOfPages;
  
    int index = 0;
    if([self selectedFile] != nil) {
        int count = 0;
        for(NSString *imageFullPath in filteredImageFullPathArray) {
            if ([self selectedFile] != nil && [[self selectedFile] isEqualToString:imageFullPath]) {
                index = count;
                break;
            }
            count++;
        }
    }
    self.pageControl.currentPage = index;
        
    //init with the most common
    self.currentViewController = self.imageController1;
    self.prevViewController = self.imageController2;
    self.nextViewController = self.imageController3;
        
    //check
    self.prevViewController = [self replace:self.prevViewController forFileAt:index-1];
    self.currentViewController = [self replace:self.currentViewController forFileAt:index];
    self.nextViewController = [self replace:self.nextViewController forFileAt:index+1];
        
    [self loadScrollViewWithPage:index controller:self.currentViewController async:NO];
    if(index >= 0) {
        CGRect frame = [self snapImageAt:index];
        [scrollView scrollRectToVisible:frame animated:NO];
    }
    //preload the previous and next images
    [self loadScrollViewWithPage:index + 1 controller:self.nextViewController async:YES];
    [self loadScrollViewWithPage:index - 1 controller:self.prevViewController async:YES];
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
        [self hideHUDView];
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
