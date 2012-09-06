//
//  ACScroolViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 03.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACController.h"
#import "ACImageViewController.h"
#import "ACMovieViewController.h"
//#import "ACDeviceManager.h"

@interface ACScrollViewController : UIViewController <UIScrollViewDelegate, /*ACDeviceManagerDelegate,*/ UIActionSheetDelegate> {
	NSTimer *myTimer;
    CGFloat currentPageFraction;
    
    //ACDevice *deviceToSelect;
    
    BOOL pageControlUsed;
    BOOL rotating;
    NSUInteger kNumberOfPages;
    NSString *currentDirPath;
    NSString *selectedFile;
    NSMutableArray *filteredImageFullPathArray;
	
	UIBarButtonItem *playButton;
	UIBarButtonItem *pauseButton;
	UIBarButtonItem *forwardButton;
	UIBarButtonItem *rewindButton;
	UIBarButtonItem *airplayButton;
	UIBarButtonItem *flexItemLeft;
	UIBarButtonItem *fixItemLeft;
	UIBarButtonItem *flexItemRight;
	UIBarButtonItem *fixItemRight;
	
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIPageControl *pageControl;
    
    ACImageViewController *imageController1;
    ACImageViewController *imageController2;
    ACImageViewController *imageController3;
    
    ACMovieViewController *movieController1;
    ACMovieViewController *movieController2;
    ACMovieViewController *movieController3;
	
	UIViewController<ACController> *prevViewController;
	UIViewController<ACController> *currentViewController;
	UIViewController<ACController> *nextViewController;
}

//@property (nonatomic, retain) ACDevice *deviceToSelect;

@property (nonatomic) BOOL pageControlUsed;
@property (nonatomic) BOOL rotating;
@property (nonatomic) NSUInteger kNumberOfPages;
@property (nonatomic, retain) NSString *selectedFile;
@property (nonatomic, retain) NSString *currentDirPath;
@property (nonatomic, retain) NSMutableArray *filteredImageFullPathArray;

@property (nonatomic, retain) UIBarButtonItem *playButton;
@property (nonatomic, retain) UIBarButtonItem *pauseButton;
@property (nonatomic, retain) UIBarButtonItem *forwardButton;
@property (nonatomic, retain) UIBarButtonItem *rewindButton;
@property (nonatomic, retain) UIBarButtonItem *airplayButton;
@property (nonatomic, retain) UIBarButtonItem *flexItemLeft;
@property (nonatomic, retain) UIBarButtonItem *fixItemLeft;
@property (nonatomic, retain) UIBarButtonItem *flexItemRight;
@property (nonatomic, retain) UIBarButtonItem *fixItemRight;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

@property (nonatomic, retain) ACImageViewController *imageController1;
@property (nonatomic, retain) ACImageViewController *imageController2;
@property (nonatomic, retain) ACImageViewController *imageController3;

@property (nonatomic, retain) ACMovieViewController *movieController1;
@property (nonatomic, retain) ACMovieViewController *movieController2;
@property (nonatomic, retain) ACMovieViewController *movieController3;

@property (nonatomic, retain) UIViewController<ACController> *prevViewController;
@property (nonatomic, retain) UIViewController<ACController> *currentViewController;
@property (nonatomic, retain) UIViewController<ACController> *nextViewController;

- (NSString *)currentFile;
- (NSString *)currentDirectory;
- (IBAction)changePage:(id)sender;

- (void)selectFile:(NSString *)file;
- (void)load;
- (void)setFile:(NSString *)file inFolder:(NSString *)dirPath withContent:(NSMutableArray *)imageFullPathArray;

- (void)play;
- (void)pause;
- (void)next:(NSTimer *)timer;
- (void)previous:(NSTimer *)timer;
- (void)airplay;

- (void)clearViewControllers;

@end
