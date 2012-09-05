//
//  Class.h
//  AC234
//
//  Created by Stéphane Rossé on 02.04.11.
//  Copyright 2011 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACThumbnailsTableController.h"
#import "ACLargeThumbnailListCell.h"

@interface ACLargeFolderController : ACThumbnailsTableController <UITableViewDelegate, UITableViewDataSource> {
    int lastSelectedRow;
    int lastCellForRow;
    int firstRowToThumbnail;
    int numOfThumbnailPerLine;
    
    NSString *folderPath;
	NSString *folderTildePath;
	NSMutableArray *folderList;
	
	UIViewController *parentSlideViewController;
}

@property (nonatomic, retain) NSString *folderPath;
@property (nonatomic, retain) NSString *folderTildePath;
@property (nonatomic, retain) NSMutableArray *folderList;

@property (nonatomic, retain) UIViewController *parentSlideViewController;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath iconAt:(NSUInteger)index;

- (void)loadFolder:(NSString *)folder withImages:(NSMutableArray *)filePaths fromSlideView:(UIViewController *)slider;
- (void)selectFile:(NSString *)file;

- (void)loadThumbnailInCell:(ACLargeThumbnailListCell *)cell atRow:(int)row forImage:(NSString *)filename;

- (void)fillThumbnailsBufferAt:(int)row waitUntilFilled:(BOOL)wait;

@end
