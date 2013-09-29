//
//  FolderListCell.h
//  AC234
//
//  Created by Stéphane Rossé on 14.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACThumbnailCell.h"


@interface ACFolderListCell : UITableViewCell <ACThumbnailCell> {
	NSString *filename;
	UIImage *thumbnail;
    UIView *cellContentView;
	UIColor *fontColor;
}

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UIColor *fontColor;
@property (nonatomic, retain) UIView *cellContentView;

- (void)setRow:(int)row;

@end
