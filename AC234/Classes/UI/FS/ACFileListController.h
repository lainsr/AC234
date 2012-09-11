//
//  ACFileListController.h
//  AC234
//
//  Created by Stéphane Rossé on 02.09.12.
//
//

#import <Foundation/Foundation.h>
#import "ACToolbar.h"
#import "ACThumbnailsTableController.h"

typedef enum {
    kList,
    kLarge,
} CellRenderType;


@interface ACFileListController : ACThumbnailsTableController
    <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    int lastSelectedRow;
    int lastCellForRow;
    int firstRowToThumbnail;
    int numOfThumbnailPerCell;
      
    BOOL hasChanged;
    BOOL editMode;
    CellRenderType cellStyle;
        
    NSString *folderPath;
    NSString *folderTildePath;
    NSMutableArray *folderList;
        ACFileListController *subController;
        
    UIBarButtonItem *backButtonBackup;
    UIBarButtonItem *rightButtonBackup;
        
    IBOutlet ACToolbar *flipToolbar;
    IBOutlet UIButton *flipIndicatorButton;
	IBOutlet UIBarButtonItem *organizeButton;
	IBOutlet UIBarButtonItem *addButton;
	IBOutlet UIBarButtonItem *cancelEditButton;
    
}

@property(readwrite) int lastSelectedRow;
@property(readwrite) int lastCellForRow;
@property(readwrite) int firstRowToThumbnail;
@property(readwrite) int numOfThumbnailPerCell;

@property(readwrite) BOOL hasChanged;
@property(readwrite) BOOL editMode;
@property(readwrite) CellRenderType cellStyle;

@property(readwrite, strong) NSString *folderPath;
@property(readwrite, strong) NSString *folderTildePath;
@property(readwrite, strong) NSMutableArray *folderList;
@property(readwrite, strong) ACFileListController *subController;

@property(readwrite, strong) UIBarButtonItem *backButtonBackup;
@property(readwrite, strong) UIBarButtonItem *rightButtonBackup;

@property(readwrite, strong) IBOutlet ACToolbar *flipToolbar;
@property(readwrite, strong) IBOutlet UIButton *flipIndicatorButton;
@property(readwrite, strong) IBOutlet UIBarButtonItem *organizeButton;
@property(readwrite, strong) IBOutlet UIBarButtonItem *addButton;
@property(readwrite, strong) IBOutlet UIBarButtonItem *cancelEditButton;


- (IBAction)organize;
- (IBAction)addPhoto;
- (IBAction)editFolder;
- (IBAction)flipCurrentView;

- (void)loadFolder:(NSString *)folder;

@end
