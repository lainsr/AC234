//
//  ACSearchViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 31.08.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACScrollViewController.h"
#import "ACLoadThumbnailsOperation.h"
#import "ACThumbnailsTableController.h"

@interface ACSearchViewController : ACThumbnailsTableController <UISearchDisplayDelegate, UISearchBarDelegate, UINavigationControllerDelegate> {
	IBOutlet UISearchBar *searchBar;
	
	int lastCellForRow;
	int firstRowToThumbnail;
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *filteredListContent;

- (void)keyboardWillHide:(NSNotification *)notification;
- (void)hideNavbarAndKeepHidden;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

- (void)fillThumbnailsBufferAt:(int)row waitUntilFilled:(BOOL)wait;

- (NSString *)healPath:(NSString*)dirtyPath operation:(NSNumber **)needed;

@end
