//
//  ACThumbnailCollectionView.m
//  AC234
//
//  Created by Stéphane Rossé on 10.10.12.
//
//
#import "ACStaticIcons.h"
#import "ACGlobalInfos.h"
#import "ACThumbnailCollectionView.h"

@implementation ACThumbnailCollectionView

@synthesize thumbnail;


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat scale = [[ACGlobalInfos sharedInstance] scale];

    CGContextClipToRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height));
    
    CGFloat cellWidth = rect.size.width - 4.0f;
    CGFloat cellHeight = rect.size.height - 4.0f;

    CGImageRef image = CGImageRetain([thumbnail CGImage]);
    size_t width = CGImageGetWidth(image) / scale;
    CGFloat wOffset = (cellWidth - width) / 2.0f;
    size_t height = CGImageGetHeight(image) / scale;
    CGFloat hOffset = (cellHeight - height) / 2.0f;
        
    CGRect imageRect = CGRectMake(0.0f, 0.0f, width, height);
        
    CGContextTranslateCTM(context, wOffset, hOffset);
    //CGContextSetShadowWithColor(context, CGSizeMake(2.0f, 2.0f), 1.0f, [[ACStaticIcons darkBackground] CGColor]);
        
    CGContextDrawImage(context, imageRect, image);
    CGImageRelease(image);

}

@end
