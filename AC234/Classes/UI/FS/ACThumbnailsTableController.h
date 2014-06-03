//
//  ACThumbnailsTableController.h
//  AC234
//
//  Created by Stéphane Rossé on 05.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_OF_THUMBNAILS 10

@interface ACThumbnailsTableController : UITableViewController <UITableViewDelegate> {
    UIDeviceOrientation renderedOrientation;
}

@property (nonatomic) UIDeviceOrientation renderedOrientation;

- (void)updateOrientation;
- (void)doUpdateOrientation;

-(NSString*)currentVisibleFile;

int sortAscending(id interval1, id interval2, void *locale);

@end
