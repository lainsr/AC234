//
//  ACThumbnailsTableController.m
//  AC234
//
//  Created by Stéphane Rossé on 05.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "ACThumbnailsTableController.h"

@implementation ACThumbnailsTableController

@synthesize thumbnailBuffer, renderedOrientation;

- (void)viewDidLoad {
    ACLRUDictionary *thumbnails = [[ACLRUDictionary alloc] initWithCapacity:DEFAULT_CACHE_SIZE * 2 + 1];
	self.thumbnailBuffer = thumbnails;
	[super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self updateOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self updateOrientation];
}

- (void)updateOrientation {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation != self.renderedOrientation) {
        [self doUpdateOrientation];
        [self setRenderedOrientation:deviceOrientation];
    }
}

- (void)doUpdateOrientation {
    //
}

#pragma mark -
#pragma mark ACUpdateThumbnailsOperationDelegate
-(NSString*)currentVisibleFile{
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 37.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	//
}

#pragma mark -
#pragma mark ACLoadThumbnailsOperation
-(void) thumbnailFinished:(UIImage*)image forFile:(NSString*)filename {
	[thumbnailBuffer setObject:image forKey:filename];
	[thumbnailBuffer cancelReservationForKey:filename];
}

@end
