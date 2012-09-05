//
//  ACWithHUIViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 19.05.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import "ACWithHUIViewController.h"


@interface ACWithHUIViewController (PrivateMethods)

- (void)toggleInformations;

- (void)showHUDView:(NSTimer *)timer;

- (void)clipHUDView;

@end

@implementation ACWithHUIViewController

@synthesize informations, informationsHud;
@synthesize imagePath, imageIndex, numberOfPages;

#pragma mark - View lifecycle
- (void)viewDidUnload {
    self.imagePath = nil;
    self.numberOfPages = 0;
    self.imageIndex = -1;
    self.informations = nil;
	self.informationsHud = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark UIResponder
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSUInteger numTaps = [[touches anyObject] tapCount];
	if (numTaps == 1) {
		[self toggleInformations];
	}
}

#pragma mark - HUD View
- (void)hideHUDView {
	if (informationsHud.hidden) return;
	
	informationsHud.alpha = 0.00;
    informationsHud.hidden = YES;
	
    UIApplication *sharedApp = [UIApplication sharedApplication];
    
	[sharedApp setStatusBarHidden:YES animated:NO];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)toggleInformations {
	
	if(myTimer != nil) {
		[myTimer invalidate];
		myTimer = nil;
	}
	
	if (informationsHud.hidden) {
		UIApplication *sharedApp = [UIApplication sharedApplication];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *fileName = [fileManager displayNameAtPath:imagePath];
		if(fileName == nil) {
			[self hideHUDView];
		} else {
			NSMutableString *infos = [[NSMutableString alloc] initWithString:fileName];
            
			[infos appendString:@"\n"];
			[infos appendFormat:@"%i",imageIndex];
			[infos appendString:@" / "];
			[infos appendFormat:@"%i",numberOfPages];
			informations.text = infos;
            
			informationsHud.hidden = NO;
			informationsHud.alpha = 0.00;//usefull for the first time only
            
            CGRect navFrame = [self.navigationController.navigationBar frame];
            informationsHud.frame = CGRectMake(0, 20 + navFrame.size.height + 10, navFrame.size.width, 0);
            
            myTimer = [NSTimer timerWithTimeInterval:0.15 target:self selector:@selector(showHUDView:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];
            
			[sharedApp setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
			[sharedApp setStatusBarHidden:NO animated:NO];
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
    informationsHud.alpha = 1.0;
    informationsHud.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    [self clipHUDView];
    [UIView commitAnimations];
}

- (void)clipHUDView {
    CGRect navFrame = [self.navigationController.navigationBar frame];
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        informationsHud.frame = CGRectMake(0, 20 + navFrame.size.height + 10, navFrame.size.width, 44);
    } else {
        informationsHud.frame = CGRectMake(0, 20 + navFrame.size.height + 10, navFrame.size.width, 64);
    }
}


@end
