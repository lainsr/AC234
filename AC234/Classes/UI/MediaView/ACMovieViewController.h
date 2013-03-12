//
//  ACMovieViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 01.05.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ACController.h"


@interface ACMovieViewController : UIViewController <ACController> {
    BOOL stopped;
    BOOL playing;
	
    IBOutlet UIButton *playButton;
    IBOutlet UIImageView *screenshotView;
    
    MPMoviePlayerViewController *moviePlayerView;
    UINavigationController *scrollViewNavigation;

	NSURL *movieURL;
	NSString *imagePath;
}

@property (readwrite) BOOL stopped;
@property (readwrite) BOOL playing;

@property (readwrite, strong) MPMoviePlayerController *moviePlayer;
@property (readwrite, strong) MPMoviePlayerViewController *moviePlayerView;
@property (readwrite, strong) UINavigationController *scrollViewNavigation;

@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIImageView *screenshotView;

@property (copy) NSString *imagePath;
@property (nonatomic, strong) NSURL *movieURL;

- (void)setMoviePlayerUserSettings;

- (IBAction)play;
- (void)playMovie;
- (void)stopMovie;

- (CGFloat)retrievePlaybackTime;
- (void)savePlaybackTime:(CGFloat)time;

@end
