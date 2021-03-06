//
//  ACLargeThumbnailListCell.h
//  AC234
//
//  Created by Stéphane Rossé on 06.04.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACThumbnailCell.h"

@interface ACLargeThumbnailListCell : UITableViewCell <ACThumbnailCell> {
    NSString *firstFilename;
	NSInteger row;
    IBOutlet UIView *cellContentView;
	NSMutableArray *thumbnails;
}

@property (nonatomic, copy) NSString *firstFilename;
@property (nonatomic, retain) NSMutableArray *thumbnails;
@property (nonatomic) NSInteger row;

- (void)removeAllThumbnails;

@end
