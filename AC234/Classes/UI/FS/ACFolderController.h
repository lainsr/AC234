//
//  FolderListController.h
//  AC234
//
//  Created by Stéphane Rossé on 20.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACThumbnailsTableController.h"

@interface ACFolderController : ACThumbnailsTableController <UITableViewDataSource> {
	
    int lastSelectedRow;
    int lastCellForRow;
    int firstRowToThumbnail;
    
    BOOL hasChanged;
	NSString *folderPath;
	NSString *folderTildePath;
	NSMutableArray *folderList;
	
	UIViewController *parentSlideViewController;
	IBOutlet UINavigationController *navigationController;
}

@property (nonatomic) BOOL hasChanged;
@property (nonatomic, retain) NSString *folderPath;
@property (nonatomic, retain) NSString *folderTildePath;
@property (nonatomic, retain) NSMutableArray *folderList;

@property (nonatomic, retain) UIViewController *parentSlideViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void)edit;
- (void)deselect;
- (int)indexPathForSelectedRow;
- (void)loadFolder:(NSString *)folder withImages:(NSMutableArray *)filePaths fromSlideView:(UIViewController *)slider;
- (void)selectFile:(NSString *)file;

- (void)startThumbnailAt:(int)row;
- (void)fillThumbnailsBufferAt:(int)row waitUntilFilled:(BOOL)wait;

@end
