//
//  ACThumbnailsTableController.h
//  AC234
//
//  Created by Stéphane Rossé on 05.11.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACLRUDictionary.h"
#import "ACLoadThumbnailsOperation.h"

#define DEFAULT_CACHE_SIZE 36
#define PANIC_SIZE 35
#define PANIC_OPERATION_QUEUE_SIZE 0
#define NUM_OF_THUMBNAILS 10

@interface ACThumbnailsTableController : UITableViewController <UITableViewDelegate, ACLoadThumbnailsOperationDelegate> {
	ACLRUDictionary *thumbnailBuffer;
    UIDeviceOrientation renderedOrientation;
}

@property (nonatomic, retain) ACLRUDictionary *thumbnailBuffer;
@property (nonatomic) UIDeviceOrientation renderedOrientation;

- (void)updateOrientation;
- (void)doUpdateOrientation;

-(NSString*)currentVisibleFile;

int sortAscending(id interval1, id interval2, void *locale);

@end
