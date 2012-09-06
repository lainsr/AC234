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
#import "ACWithHUIViewController.h"


@interface ACMovieViewController : ACWithHUIViewController <ACController> {
    BOOL stopped;
    BOOL playing;
	
    IBOutlet UIButton *playButton;
    IBOutlet UIImageView *screenshotView;
    
	MPMoviePlayerController *moviePlayer;
    MPMoviePlayerViewController *moviePlayerView;

	NSURL *movieURL;
}

@property (readwrite) BOOL stopped;
@property (readwrite) BOOL playing;

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;
@property (readwrite, retain) MPMoviePlayerViewController *moviePlayerView;

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIImageView *screenshotView;

@property (nonatomic, retain) NSURL *movieURL;

- (void)setMoviePlayerUserSettings;

- (IBAction)play;
- (void)playMovie;
- (void)stopMovie;

- (CGFloat)retrievePlaybackTime;
- (void)savePlaybackTime:(CGFloat)time;

- (void)toggleInformations;

@end
