//
//  ACHThumbnailViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 10.10.12.
//
//

#import <Foundation/Foundation.h>
#import "ACScrollViewController.h"

@interface ACHThumbnailViewController : UICollectionViewController {

    NSString *currentDirPath;
    NSString *selectedFile;
    NSMutableArray *folderList;
    NSString *folderTildePath;
    
    ACScrollViewController *parentController;
    
    IBOutlet UICollectionView *thumbnailCollectionViews;
}

@property (nonatomic, strong) NSString *selectedFile;
@property (nonatomic, strong) NSString *currentDirPath;
@property (nonatomic, strong) NSMutableArray *folderList;
@property (nonatomic, strong) NSString *folderTildePath;

@property(nonatomic, weak) ACScrollViewController *parentController;

@property(nonatomic, strong) IBOutlet UICollectionView *thumbnailCollectionViews;

@end
