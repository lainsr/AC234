/*
File: ACImageViewController.h
Version: 1.0
*/

#import <UIKit/UIKit.h>
#import "ACController.h"

@interface ACImageViewController : UIViewController <ACController> {
	
    IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activityView;
    
    BOOL rotating;
	NSString *imagePath;
	NSString *loadedImagePath;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;

@property (copy) NSString *imagePath;
@property (copy) NSString *loadedImagePath;

- (NSString *)healPath:(NSString*)dirtyPath;

@end
