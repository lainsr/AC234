//
//  ACScroolViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 03.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACController.h"
#import "ACHUDView.h"
#import "ACImageViewController.h"
#import "ACMovieViewController.h"
#import "ACDeviceManager.h"

@interface ACScrollViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate,
    ACDeviceManagerDelegate, UIActionSheetDelegate> {
	NSTimer *myTimer;
    CGFloat currentPageFraction;
    
    ACDevice *deviceToSelect;
    
    BOOL pageControlUsed;
    BOOL rotating;
    NSString *currentDirPath;
    NSString *selectedFile;
    NSMutableArray *filteredImageFullPathArray;
	
	IBOutlet UIBarButtonItem *playButton;
	IBOutlet UIBarButtonItem *pauseButton;
	IBOutlet UIBarButtonItem *forwardButton;
	IBOutlet UIBarButtonItem *rewindButton;
	IBOutlet UIBarButtonItem *airplayButton;
	IBOutlet UIBarButtonItem *flexItemLeft;
	IBOutlet UIBarButtonItem *fixItemLeft;
	IBOutlet UIBarButtonItem *flexItemRight;
	IBOutlet UIBarButtonItem *fixItemRight;
	
	IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIView *miniContainerView;

    IBOutlet UILabel *informations;
	IBOutlet ACHUDView *informationsHud;
    
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

@property (nonatomic, retain) ACDevice *deviceToSelect;

@property (nonatomic) BOOL pageControlUsed;
@property (nonatomic) BOOL rotating;
@property (nonatomic, strong) NSString *selectedFile;
@property (nonatomic, strong) NSString *currentDirPath;
@property (nonatomic, strong) NSMutableArray *filteredImageFullPathArray;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *playButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pauseButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *rewindButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *airplayButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *flexItemLeft;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *fixItemLeft;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *flexItemRight;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *fixItemRight;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UIView *miniContainerView;

@property (nonatomic, strong) IBOutlet UILabel *informations;
@property (nonatomic, strong) IBOutlet ACHUDView *informationsHud;

@property (nonatomic, strong) ACImageViewController *imageController1;
@property (nonatomic, strong) ACImageViewController *imageController2;
@property (nonatomic, strong) ACImageViewController *imageController3;

@property (nonatomic, strong) ACMovieViewController *movieController1;
@property (nonatomic, strong) ACMovieViewController *movieController2;
@property (nonatomic, strong) ACMovieViewController *movieController3;

@property (nonatomic, strong) UIViewController<ACController> *prevViewController;
@property (nonatomic, strong) UIViewController<ACController> *currentViewController;
@property (nonatomic, strong) UIViewController<ACController> *nextViewController;

- (NSString *)currentFile;
- (NSString *)currentDirectory;
- (IBAction)changePage:(id)sender;

- (void)selectFile:(NSString *)file;
- (void)load;
- (void)setFile:(NSString *)file inFolder:(NSString *)dirPath withContent:(NSMutableArray *)imageFullPathArray;

- (IBAction)play;
- (IBAction)pause;
- (IBAction)next;
- (IBAction)previous;
- (IBAction)airplay;

- (void)clearViewControllers;
- (void)changeBackgroundColor:(UIColor *)color;

@end
