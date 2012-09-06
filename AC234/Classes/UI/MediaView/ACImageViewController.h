/*
File: ACImageViewController.h
Version: 1.0
*/

#import <UIKit/UIKit.h>
#import "ACController.h"
#import "ACWithHUIViewController.h"

@interface ACImageViewController : ACWithHUIViewController <ACController> {
	
    IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activityView;

	NSString *loadedImagePath;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;

@property (copy) NSString *loadedImagePath;

- (NSString *)healPath:(NSString*)dirtyPath;
- (void)mergeChanges:(NSNotification *)notification;

@end
