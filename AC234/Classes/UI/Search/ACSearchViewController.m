//
//  ACSearchViewController.m
//  AC234
//
//  Created by Stéphane Rossé on 31.08.10.
//  Copyright 2010 Cyberiacafe. All rights reserved.
//

#import "File.h"
#import "ACScaler.h"
#import "ACStaticIcons.h"
#import "ACFileInfo.h"
#import "ACFolderListCell.h"
#import "ACAppDelegate.h"
#import "ACSearchViewController.h"
#import "ACFileListController.h"

@implementation ACSearchViewController

static NSString *kCellID = @"cellID";

@synthesize filteredListContent, subController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	self.filteredListContent = [NSMutableArray arrayWithCapacity:100];

	[super viewDidLoad];
    [self setTitle:@"Search"];
    [self.navigationController setDelegate:self];
	[self hideNavbarAndKeepHidden];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.filteredListContent = [NSMutableArray arrayWithCapacity:100];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *file = (NSString *)sender;
    UIViewController *destinationController = [segue destinationViewController];
    if([destinationController isKindOfClass: [ACScrollViewController class]]) {
        NSMutableArray *folderList = [[NSMutableArray alloc] initWithCapacity:[self.filteredListContent count]];
		for(ACFileInfo *f in [self filteredListContent]) {
            [folderList addObject:[f fullPath]];
		}
        ACScrollViewController *scrollController = (ACScrollViewController *)destinationController;
        [scrollController setFile:file inFolder:NULL withContent:folderList];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
	[self.navigationController setNavigationBarHidden:YES];
}

- (void)hideNavbarAndKeepHidden {
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];   
}

#pragma mark -
#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationCtlr
	willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
   if([viewController isKindOfClass:[ACSearchViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [[self.navigationController navigationBar] setTranslucent:NO];
        [self.navigationController setToolbarHidden:YES animated:NO];
        UIApplication *sharedApp = [UIApplication sharedApplication];
        [sharedApp setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
   }
}

- (void)navigationController:(UINavigationController *)navigationCtlr
	didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if([viewController isKindOfClass:[ACScrollViewController class]] || [viewController isKindOfClass:[ACFileListController class]] ) {
        UIApplication *sharedApp = [UIApplication sharedApplication];
        [sharedApp setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        //hide bars and set them as transparent
		[[self.navigationController navigationBar] setTranslucent:YES];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        //prepare the toolbar but hide it
        [[self.navigationController toolbar] setTranslucent:YES];
        [self.navigationController setToolbarHidden:YES animated:NO];
		[self.navigationController setDelegate:self];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int rowIndex = [indexPath indexAtPosition:1];
    if(rowIndex >= [self.filteredListContent count]) {
        //security check
        return;
    }
	
	ACFileInfo *info = [self.filteredListContent objectAtIndex:rowIndex];
    NSNumber *healthOpNeeded = NULL;
	NSString *filename = [self healPath:[info fullPath] operation:&healthOpNeeded];
	
	BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir] && !isDir) {
        [self performSegueWithIdentifier:@"SearchMediaSegue" sender:filename];
	} else {
        if(self.subController == NULL) {
            self.subController = [[self storyboard] instantiateViewControllerWithIdentifier:@"FileListA"];
        }
        [[self navigationController] pushViewController:self.subController animated:YES];
        [self.subController loadFolder:filename];
    }
}

- (NSString *)healPath:(NSString*)dirtyPath operation:(NSNumber **)needed {
	//wrong path??? try to heal it
	if(dirtyPath != nil) {
        NSString *documentPath = [(ACAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
		NSRange range = [dirtyPath rangeOfString:documentPath];
		int location = range.location;
		if(location != 0) {
			NSRange replacementRange = NSMakeRange(0, [documentPath length]);
            *needed = [NSNumber numberWithBool:YES];
            return [dirtyPath stringByReplacingCharactersInRange:replacementRange withString:documentPath];
		}
	}
    *needed = [NSNumber numberWithBool:NO];
	return dirtyPath;
}

#pragma mark -
#pragma mark UITableViewDataSource
// tell our table how many rows it will have, in our case the size of our menuList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.filteredListContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	ACFolderListCell *cell = (ACFolderListCell *)[tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil) {
		cell = [[ACFolderListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
	} else {
        [cell addThumbnail:NULL];
    }
	
	ACFileInfo *info = [self.filteredListContent objectAtIndex:indexPath.row];
	NSString *filename = [info filename];
	NSString *fullPath = [info fullPath];
	cell.filename = filename;
	[cell setRow:indexPath.row];
	
	if(firstRowToThumbnail >= 0) {
		int row = [indexPath row];
		if(row < (firstRowToThumbnail - NUM_OF_THUMBNAILS)) {
			return cell;
		}
		firstRowToThumbnail = -1;
	}
	
    ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate thumbnailQueue] addOperationWithBlock:^{
        
        ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
        ACCoreDataStore *thumbnailStore = [appDelegate thumbnailStore];
        NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [localContext setPersistentStoreCoordinator: [thumbnailStore persistentStoreCoordinator]];
        [localContext setUndoManager:NULL];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:thumbnailStore selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification object:localContext];
        
        UIImage *thumbnail = [ACScaler scale:localContext atPath:fullPath size:NO];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(thumbnail == NULL) {
                NSLog(@"Null thumbnail %@",filename);
            } else if([cell.filename isEqualToString:filename]) {
                [cell addThumbnail:thumbnail];
                [cell setNeedsLayout];
            }
        }];
    }];
	
	lastCellForRow = indexPath.row;
	return cell;
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	if(searchText == nil || [searchText length] < 2) {
		return;
	}
	
	NSNumber *type;
	if (scope == nil || [scope length] == 0) {
		type = nil;
	} else if([@"Images" isEqualToString:scope]) {
		type = [NSNumber numberWithInt:0];
	} else if([@"Videos" isEqualToString:scope]) {
		type = [NSNumber numberWithInt:2];
	} else {
		type = nil;
	}

	ACAppDelegate *appDelegate = (ACAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:[appDelegate.thumbnailStore managedObjectContext]];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entity];
	[request setResultType:NSDictionaryResultType];
	[request setReturnsDistinctResults:YES];
	[request setPropertiesToFetch:[NSArray arrayWithObjects:@"fullPath",@"name",nil]];
	
	if(searchText != nil && [searchText length] > 0 && type != nil) {
		[request setPredicate:[NSPredicate predicateWithFormat:@"name contains[c] %@ AND type == %@", searchText, type]];
	} else if(searchText != nil && [searchText length] > 0) {
		[request setPredicate:[NSPredicate predicateWithFormat:@"name contains[c] %@", searchText]];
	} else if (type != nil) {
		[request setPredicate:[NSPredicate predicateWithFormat:@"type == %@", type]];
	} else {
		return;
	}
	
	NSError *error;
	NSArray *results = [[appDelegate.thumbnailStore managedObjectContext] executeFetchRequest:request error:&error];
	
	[self.filteredListContent removeAllObjects];
	for(NSDictionary *result in results) {
		NSString *fullPath = [result objectForKey:@"fullPath"];
		NSString *filename = [result objectForKey:@"name"];
	
		ACFileInfo *info = [[ACFileInfo alloc] initWithFilename:filename atFullPath:fullPath];
		[self.filteredListContent addObject:info];
	}
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    //table view forget its settings3
    tableView.separatorColor = self.tableView.separatorColor;
	tableView.separatorStyle = self.tableView.separatorStyle;
    tableView.backgroundColor = self.tableView.backgroundColor;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    //
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	[self filterContentForSearchText:searchString scope:
		[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
		[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
	// Return YES to cause the search result table view to be reloaded.
	return YES;
}

@end
