//
//  ACMovieViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 01.05.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "Movie.h"
#import "ACScaler.h"
#import "ACAppDelegate.h"
#import "ACMovieViewController.h"
#import <QuartzCore/QuartzCore.h>

NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";

CGFloat kMovieViewOffsetX = 20.0;
CGFloat kMovieViewOffsetY = 20.0;

@interface ACMovieViewController(MovieControllerInternal)
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType;
-(void)applyUserSettingsToMoviePlayer;
-(void)moviePlayBackDidFinish:(NSNotification*)notification;
-(void)loadStateDidChange:(NSNotification *)notification;
-(void)moviePlayBackStateDidChange:(NSNotification*)notification;
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification;
-(void)installMovieNotificationObservers;
-(void)removeMovieNotificationHandlers;
-(void)deletePlayerAndNotificationObservers;
@end


@implementation ACMovieViewController

@synthesize moviePlayer, moviePlayerView, screenshotView, playButton;
@synthesize movieURL, stopped, playing;

- (id)init {
    self = [super initWithNibName:@"ACMovieView" bundle:nil];
	if (self) {
		[self setHidesBottomBarWhenPushed:YES];
		[self setWantsFullScreenLayout:YES];
        self.view.backgroundColor = [UIColor blackColor];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (IBAction)play {
    [self playMovie];
}

#pragma mark -
#pragma mark ACController
- (void)clearView {
	//
}

- (void)willLoad:(NSString *)path at:(int)index {
    [self setImageIndex:index];
	[self setImagePath:path];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if(self.movieURL == NULL && ![self.movieURL isEqual:url]) {
        self.movieURL = url;
	} 
}

- (void)didLoad:(NSString *)path at:(int)index {
	[self setImageIndex:index];
	[self setImagePath:path];
	
    NSURL *url = [NSURL fileURLWithPath:path];
	if(self.movieURL != NULL && [self.movieURL isEqual:url]) {
		[self.moviePlayer play];
	} else {
        self.movieURL = url;
        //[self playMovie];
    }
}

- (void)willUnload:(NSString *)path at:(int)index {
    [self deletePlayerAndNotificationObservers];
	//resume don't work
	[self setMovieURL:NULL];
	[self setMoviePlayer:NULL];
    [self setMoviePlayerView:NULL];
}

- (void)didUnload:(NSString *)path at:(int)index { }

- (void)updateViewAfterOrientationChange:(BOOL)async { 
    /* Size movie view to fit parent view. */
    if([self moviePlayer] != NULL) {
        CGRect viewInsetRect = CGRectInset ([self.view bounds], 0, 0 );
        [[[self moviePlayer] view] setFrame:viewInsetRect];
    }
}

#pragma mark -
#pragma mark Movie

- (void)playMovie {
    if (!informationsHud.hidden) {
		informationsHud.alpha = 0.0;
		informationsHud.hidden = YES;
		playButton.hidden = NO;
	}
    
    if(self.moviePlayer != NULL) {
        [self setStopped:NO];
        [self setPlaying:YES];
        [self.navigationController presentMoviePlayerViewControllerAnimated:[self moviePlayerView]];
        return;
    }
	
	MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
	if (mp.moviePlayer) {
		self.moviePlayer = mp.moviePlayer;
        self.moviePlayerView = mp;
        [self setMoviePlayerUserSettings];
        [self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
        [self installMovieNotificationObservers];
        
        CGFloat time = [self retrievePlaybackTime];
        if(time > 1.0f) {
            self.moviePlayer.initialPlaybackTime = time;
        }
        [self setStopped:NO];
        [self setPlaying:YES];
        [self.navigationController presentMoviePlayerViewControllerAnimated:[self moviePlayerView]];
	}
}

- (void)stopMovie {
    if(self.stopped == NO) {
        [self setStopped:YES];
        [self setPlaying:NO];
        [self.moviePlayer stop];
        [self.moviePlayer.view removeFromSuperview];
        [self deletePlayerAndNotificationObservers];
    }
}

- (void)savePlaybackTime:(CGFloat)time {
    ACAppDelegate *delegate = (ACAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = [[delegate thumbnailStore] managedObjectContext];
    
    //found current object
    NSString *moviePath = [self imagePath];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:appContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(path == %@)", moviePath]];
	
    
    NSError *error;
	NSArray *result = [appContext executeFetchRequest:request error:&error];
    
	Movie *savedMovie;
	if([result count] == 0) {
		savedMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:appContext];
		savedMovie.path = moviePath;
	} else {
		savedMovie = [result lastObject];
	}
    
    savedMovie.playbackTime = [NSNumber numberWithFloat:time];
    
    if(![[savedMovie managedObjectContext] save:&error]) {
        NSLog(@"Cannot save movie playback informations %@, %@", error, [error userInfo]);
    }
}

- (CGFloat)retrievePlaybackTime {
    ACAppDelegate *delegate = (ACAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *appContext = [[delegate thumbnailStore] managedObjectContext];
    
    //found current object
    NSString *moviePath = [self imagePath];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:appContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"(path == %@)", moviePath]];
	
    NSError *error;
	NSArray *result = [appContext executeFetchRequest:request error:&error];
    
    CGFloat time = 0.0f;
	if([result count] > 0) {
		Movie *savedMovie = [result lastObject];
        time = [savedMovie.playbackTime floatValue];
	}
    return time;
}

#pragma mark -
#pragma mark Notifications
-(void)installMovieNotificationObservers {
    MPMoviePlayerController *player = [self moviePlayer];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadStateDidChange:) 
                                             name:MPMoviePlayerLoadStateDidChangeNotification
                                             object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                             object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mediaIsPreparedToPlayDidChange:) 
                                             name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                             object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackStateDidChange:) 
                                             name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                             object:player];
}

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers {    
    MPMoviePlayerController *player = [self moviePlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification {
	MPMoviePlayerController *player = notification.object;
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped) {
        NSTimeInterval playbackTime = [self.moviePlayer currentPlaybackTime];
        UIImage *shot = [self.moviePlayer thumbnailImageAtTime:playbackTime timeOption:MPMovieTimeOptionNearestKeyFrame];  
        ACAppDelegate *delegate = (ACAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *appContext = [[delegate thumbnailStore] managedObjectContext]; 
        [ACScaler saveDbImage:shot atPath:imagePath withContext:appContext];
        
        [self.view addSubview:[self screenshotView]];
        [self.view addSubview:[self playButton]];
        [self.screenshotView setImage:shot];
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)  {
        //NSLog(@"Playing");
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused) {
        //NSLog(@"Paused");
        [self.playButton setHidden:NO];
	}
	/* Playback is temporarily interrupted, perhaps because the buffer ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)  {
        //NSLog(@"Interrupted");
        [self.playButton setHidden:NO];
	}
}

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]; 
	switch ([reason integerValue])  {
        /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            [self stopMovie];
			break;
        /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            //[self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]  waitUntilDone:NO];
            [self stopMovie];
			break;
        /* The user stopped playback. */
		case MPMovieFinishReasonUserExited: {
            CGFloat time = [self.moviePlayer currentPlaybackTime];
            [self savePlaybackTime:time];
            [self stopMovie];
			break;
        }
		default:
			break;
	}
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification  {   
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;	
    
	/* The load state is not known at this time. */
	if (loadState & MPMovieLoadStateUnknown) {
        //[self.overlayController setLoadStateDisplayString:@"n/a"];
        //[overlayController setLoadStateDisplayString:@"unknown"];
        //NSLog(@"Load unkown");       
	}
	
	/* The buffer has enough data that playback can begin, but it 
	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable) {
        //[overlayController setLoadStateDisplayString:@"playable"];
       // NSLog(@"Load playable");
	}
	
	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK) {
        // Add an overlay view on top of the movie view
        //[self addOverlayView];
        //NSLog(@"Load OK");
        
        //[overlayController setLoadStateDisplayString:@"playthrough ok"];
	}
	
	/* The buffering of data has stalled. */
	if (loadState & MPMovieLoadStateStalled) {
        //NSLog(@"Load stalled");
	}
}

/* Notifies observers of a change in the prepared-to-play state of an object 
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    //NSLog(@"Prepared to play");
	// Add an overlay view on top of the movie view
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers {
    [self removeMovieNotificationHandlers];
    [self setMoviePlayer:nil];
    [self setMoviePlayerView:nil];
}

#pragma mark -
#pragma mark ACWithHUDViewController
- (void)toggleInformations {
    if([self moviePlayer] == nil || ![self playing]) {
        [super toggleInformations];
    }
}


#pragma mark -
#pragma mark Settings
-(void)setMoviePlayerUserSettings {
	/* First get the movie player settings defaults (scaling, controller type and background color)
	set by the user via the built-in iPhone Settings application */
	 
	NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kScalingModeKey];
	if (testValue == nil){
		// No default movie player settings values have been set, create them here based on our 
		// settings bundle info.
		//
		// The values to be set for movie playback are:
		//
		//    - scaling mode (None, Aspect Fill, Aspect Fit, Fill)
		//    - controller mode (Standard Controls, Volume Only, Hidden)
		//    - background color (Any UIColor value)
		//
        
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
		NSNumber *controlModeDefault = nil;
		NSNumber *scalingModeDefault = nil;
		NSNumber *backgroundColorDefault = nil;
        
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray) {
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			if ([keyValueStr isEqualToString:kScalingModeKey]) {
				scalingModeDefault = defaultValue;
			} else if ([keyValueStr isEqualToString:kControlModeKey]) {
				controlModeDefault = defaultValue;
			} else if ([keyValueStr isEqualToString:kBackgroundColorKey]) {
				backgroundColorDefault = defaultValue;
			}
		}
        
		// since no default values have been set, create them here
		NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
			scalingModeDefault, kScalingModeKey,
			controlModeDefault, kControlModeKey,
			backgroundColorDefault, kBackgroundColorKey, nil];
        
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	/* Now apply these settings to the active Movie Player (MPMoviePlayerController) object  */

	/* 
	Movie scaling mode can be one of: MPMovieScalingModeNone, MPMovieScalingModeAspectFit,
		MPMovieScalingModeAspectFill, MPMovieScalingModeFill.
	*/
	//self.moviePlayer.scalingMode = [[NSUserDefaults standardUserDefaults] integerForKey:kScalingModeKey];
    
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.moviePlayer.allowsAirPlay = YES;
    self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    
	/* 
	Movie control mode can be one of: MPMovieControlModeDefault, MPMovieControlModeVolumeOnly, MPMovieControlModeHidden.
	*/
	//self.moviePlayer.movieControlMode = [[NSUserDefaults standardUserDefaults] integerForKey:kControlModeKey];



}

@end
