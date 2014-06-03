//
//  ACThumbnailCollectionView.h
//  AC234
//
//  Created by Stéphane Rossé on 10.10.12.
//
//

#import <Foundation/Foundation.h>

@interface ACThumbnailCollectionView : UICollectionViewCell {

    UIImage *thumbnail;
    NSString *filename;
}

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *filename;

- (void)addThumbnail:(UIImage *)image;

@end
