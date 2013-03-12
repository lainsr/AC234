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

@synthesize scrollViewNavigation, moviePlayerView, screenshotView, playButton;
@synthesize imagePath, movieURL, stopped, playing;


- (IBAction)play {
    [self playMovie];
}

#pragma mark -
#pragma mark ACController
- (BOOL)empty {
    return [self imagePath] == NULL;
}

- (void)clearView {
	//
}

- (void)willLoad:(NSString *)path at:(int)index {
	[self setImagePath:path];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    if(self.movieURL == NULL && ![self.movieURL isEqual:url]) {
        self.movieURL = url;
	} 
}

- (void)didLoad:(NSString *)path at:(int)index {
	[self setImagePath:path];
	
    NSURL *url = [NSURL fileURLWithPath:path];
	if(self.movieURL == NULL || ![self.movieURL isEqual:url]) {
        self.movieURL = url;
    }
}

- (void)willUnload:(NSString *)path at:(int)index {
    [self deletePlayerAndNotificationObservers];
	//resume don't work
	[self setMovieURL:NULL];
    [self setMoviePlayerView:NULL];
}

- (void)didUnload:(NSString *)path at:(int)index {
    //nothing to do
}

- (void)updateViewAfterOrientationChange:(BOOL)async { 
    /* Size movie view to fit parent view. */
    if([self moviePlayerView] != NULL) {
        CGRect viewInsetRect = CGRectInset([self.view bounds], 0, 0 );
        [[[[self moviePlayerView] moviePlayer] view] setFrame:viewInsetRect];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if([self playButton] != NULL) {
        CGPoint playInsetRect;
        CGSize viewSize = [[self view] bounds].size;
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            playInsetRect = CGPointMake(viewSize.height / 2.0f, viewSize.width / 2.0f);
        } else {
            //toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown
            playInsetRect = CGPointMake(viewSize.height / 2.0f, viewSize.width / 2.0f);
        }
        [[self playButton] setCenter:playInsetRect];
    }
}

#pragma mark -
#pragma mark Movie
- (void)playMovie {
    if([self moviePlayerView] != NULL) {
        [self setStopped:NO];
        [self setPlaying:YES];
        [[[self moviePlayerView] moviePlayer] play];
        [self.playButton setHidden:YES];
    } else {
        MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
        [mp.moviePlayer setAllowsAirPlay:YES];
        if (mp.moviePlayer) {
            [self setMoviePlayerView: mp];
            [self setMoviePlayerUserSettings];
            [self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
            [self installMovieNotificationObservers];
            CGFloat time = [self retrievePlaybackTime];
            if(time > 1.0f) {
                self.moviePlayer.initialPlaybackTime = time;
            }
            [self setStopped:NO];
            [self setPlaying:YES];
            [[[self moviePlayerView] moviePlayer] play];
        }
    }
}

- (void)stopMovie {
    if(self.stopped == NO) {
        [self setStopped:YES];
        [self setPlaying:NO];
        [self.playButton setHidden:NO];
        [[[[self moviePlayerView] moviePlayer] view] removeFromSuperview];
        [self.scrollViewNavigation dismissMoviePlayerViewControllerAnimated];

        NSLog(@"stopMovie");
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
    //MPMoviePlayerLoadStateDidChange
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:) 
                                             name:MPMoviePlayerLoadStateDidChangeNotification
                                             object:player];
    //MPMoviePlayerPlaybackDidFinish
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                             name:MPMoviePlayerPlaybackDidFinishNotification
                                             object:player];
    //MPMediaPlaybackIsPreparedToPlayDidChange
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mediaIsPreparedToPlayDidChange:) 
                                             name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                             object:player];
    //MPMoviePlayerPlaybackStateDidChange
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
        
        //[self.view addSubview:[self screenshotView]];
        //[self.view addSubview:[self playButton]];
        //[self.playButton setHidden:NO];
        /*
        UIImage *scaledShot = [ACScaler loadDbImage:imagePath withContext:appContext];
        CGFloat height = (self.view.frame.size.height - scaledShot.size.height) / 2.0f;
        CGFloat width = (self.view.frame.size.width - scaledShot.size.width) / 2.0f;
        CGRect frame = CGRectMake(width, height, scaledShot.size.width, scaledShot.size.height);
        [self.screenshotView setFrame:frame];
        [self.screenshotView setImage:scaledShot];
        */
        NSLog(@"moviePlayBackStateDidChange: MPMoviePlaybackStateStopped");
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
            NSLog(@"moviePlayBackDidFinish: MPMovieFinishReasonPlaybackEnded");
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
            NSLog(@"moviePlayBackDidFinish: MPMovieFinishReasonUserExited");
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
        //NSLog(@"Load unkown");
	}
	
	/* The buffer has enough data that playback can begin, but it 
	 may run out of data before playback finishes. */
	if (loadState & MPMovieLoadStatePlayable) { 
        [self.view addSubview:[[[self moviePlayerView] moviePlayer] view]];
        [self.scrollViewNavigation presentMoviePlayerViewControllerAnimated:[self moviePlayerView]];
        //NSLog(@"Load playable");
	}
	
	/* Enough data has been buffered for playback to continue uninterrupted. */
	if (loadState & MPMovieLoadStatePlaythroughOK) {
        //NSLog(@"Load OK");
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
}

#pragma mark -
#pragma mark Settings
-(void)setMoviePlayerUserSettings {
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [self.moviePlayer setAllowsAirPlay:YES];
    self.moviePlayer.view.backgroundColor = [UIColor blueColor];
}

@end
