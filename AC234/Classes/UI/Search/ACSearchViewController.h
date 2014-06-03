//
//  ACSearchViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 31.08.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACScrollViewController.h"
#import "ACThumbnailsTableController.h"
#import "ACFileListController.h"

@interface ACSearchViewController : ACThumbnailsTableController <UISearchDisplayDelegate, UISearchBarDelegate, UINavigationControllerDelegate> {
	int lastCellForRow;
	int firstRowToThumbnail;
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    ACFileListController *subController;
}

@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, strong) ACFileListController *subController;

- (void)keyboardWillHide:(NSNotification *)notification;
- (void)hideNavbarAndKeepHidden;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

- (NSString *)healPath:(NSString*)dirtyPath operation:(NSNumber **)needed;

@end
