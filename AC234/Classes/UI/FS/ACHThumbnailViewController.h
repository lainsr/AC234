//
//  ACHThumbnailViewController.h
//  AC234
//
//  Created by Stéphane Rossé on 10.10.12.
//
//

#import <Foundation/Foundation.h>
#import "ACLRUDictionary.h"
#import "ACLoadThumbnailsOperation.h"

@interface ACHThumbnailViewController : UICollectionViewController <ACLoadThumbnailsOperationDelegate> {

    NSString *currentDirPath;
    NSString *selectedFile;
    NSMutableArray *folderList;
    NSString *folderTildePath;
    
    ACLRUDictionary *thumbnailBuffer;
    
    IBOutlet UICollectionView *thumbnailCollectionViews;
}

@property (nonatomic, strong) NSString *selectedFile;
@property (nonatomic, strong) NSString *currentDirPath;
@property (nonatomic, strong) NSMutableArray *folderList;
@property (nonatomic, strong) NSString *folderTildePath;
@property(nonatomic, strong) ACLRUDictionary *thumbnailBuffer;

@property(nonatomic, strong) IBOutlet UICollectionView *thumbnailCollectionViews;

@end
