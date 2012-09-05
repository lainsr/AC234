//
//  SwitchViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 11.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACFolderController.h"
#import "ACScrollViewController.h"
#import "ACLargeFolderController.h"


@interface ACSlideViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	
    int indexToSelect;
    int frontViewState;
    
    BOOL folders;
    BOOL changed;
	NSString *folderPath;
	NSMutableArray *folderList;
    
    NSArray *toolItems;
	ACSlideViewController *subSlideViewController;
	
	IBOutlet UIBarButtonItem *addButton;
    IBOutlet UIBarButtonItem *flipButton;
    IBOutlet UIButton *flipIndicatorButton;
	IBOutlet UIBarButtonItem *organizeButton;
	IBOutlet UIBarButtonItem *cancelEditButton;
	IBOutlet ACFolderController *folderController;
    IBOutlet ACLargeFolderController *largeFolderController;
	IBOutlet ACScrollViewController *imagesViewController;
	IBOutlet UINavigationController *navigationController;
}

@property (nonatomic) BOOL folders;
@property (nonatomic, retain) NSString *folderPath;
@property (nonatomic, retain) NSMutableArray *folderList;
@property (nonatomic, retain) IBOutlet ACFolderController *folderController;
@property (nonatomic, retain) IBOutlet ACLargeFolderController *largeFolderController;


@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *organizeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelEditButton;
@property (nonatomic, retain) IBOutlet UIButton *flipIndicatorButton;

@property (nonatomic, retain) IBOutlet ACSlideViewController *subSlideViewController;
@property (nonatomic, retain) IBOutlet ACScrollViewController *imagesViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

//load the content of the folder in the list
- (void)loadFolder:(NSString *)folder;
- (void)selectAtIndex:(int)index;
- (void)selectFile:(NSString *)file;
//load the content of the folder in a new flip list and push the view
- (void)selectFolder:(NSString *)folder;
- (IBAction)flipCurrentView;
- (IBAction)editFolder;
- (IBAction)addPhoto;
- (void)generateName:(int)number andAppendTo:(NSMutableString *)string;

- (void)willShowViewController;
- (void)willShowParentViewController;

static int finderSortWithLocale(id string1, id string2, void *locale);

@end
